module View exposing (view)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (Document)
import Browser.Navigation as Nav
import Dict
import Editable exposing (Editable(..))
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Graphql.Http
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)


view : Model -> Document Msg
view model =
    { title = "AISF"
    , body =
        [ viewBody model ]
    }


viewBody : Model -> Html Msg
viewBody model =
    layout
        [ Font.family
            [ Font.external
                { name = "Roboto"
                , url = "https://fonts.googleapis.com/css?family=Roboto:100,200,200italic,300,300italic,400,400italic,600,700,800"
                }
            ]
        , alignLeft
        , Font.size 16
        , padding 20
        ]
    <|
        case model.currentPage of
            ListPage listModel ->
                viewListPage listModel

            ChampionPage championModel ->
                viewChampionPage championModel

            NewChampionPage newChampionModel ->
                viewNewChampionPage model.currentYear newChampionModel


viewListPage : ListPageModel -> Element Msg
viewListPage model =
    column [ spacing 10 ]
        [ case model.champions of
            Success champions ->
                column [ spacing 20 ]
                    [ sportSelector True SelectedASport model.sport
                    , row [ spacing 20 ]
                        [ column [ spacing 5 ]
                            (champions
                                |> filterBySport model.sport
                                |> List.map
                                    (\champ ->
                                        link []
                                            { url = "/champions/" ++ Model.getId champ
                                            , label = text <| champ.firstName ++ " " ++ champ.lastName
                                            }
                                    )
                            )
                        , link [] { url = "/champions/new", label = el [] <| text "Ajouter champion" }
                        ]
                    ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]


filterBySport : Maybe Sport -> List Champion -> List Champion
filterBySport sport champions =
    case sport of
        Nothing ->
            champions

        Just s ->
            champions
                |> List.filter (.sport >> (==) s)


viewChampionPage : ChampionPageModel -> Element Msg
viewChampionPage { id, champion } =
    column [ spacing 10 ]
        [ link []
            { url = "/champions"
            , label = el [ Border.width 1, padding 5 ] <| text <| "Retour à la liste"
            }
        , case champion of
            Success champ ->
                column [ spacing 15 ]
                    [ column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "INFOS"
                        , column [ spacing 4 ]
                            [ viewField "N°" (Model.getId champ)
                            , viewField "Nom" champ.lastName
                            , viewField "Prénom" champ.firstName
                            , viewField "Discipline" (Model.sportToString champ.sport)
                            ]
                        ]
                    , column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "EXPÉRIENCES PROFESSIONNELLES"
                        , column [ spacing 7 ]
                            (champ.proExperiences
                                |> List.map viewProExperience
                            )
                        ]
                    , column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "PALMARÈS"
                        , column [ spacing 7 ]
                            (champ.medals
                                |> List.map viewMedal
                            )
                        ]
                    , column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "ANNÉES EN ÉQUIPE DE FRANCE"
                        , column [ spacing 7 ]
                            (if champ.yearsInFrenchTeam == [] then
                                [ text "Aucune" ]

                             else
                                champ.yearsInFrenchTeam
                                    |> List.map Model.getYear
                                    |> List.sort
                                    |> List.map
                                        (\year ->
                                            text <| String.fromInt year
                                        )
                            )
                        ]
                    ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]


viewProExperience : ProExperience -> Element Msg
viewProExperience exp =
    column [ spacing 4 ]
        [ viewField "Catégorie professionnelle" exp.occupationalCategory
        , viewField "Titre" exp.title
        , viewField "Nom de l'entreprise" exp.companyName
        , viewField "Description" exp.description
        , viewField "Site internet" exp.website
        , viewField "Contact" exp.contact
        ]


viewField : String -> String -> Element Msg
viewField label value =
    row [ spacing 10 ] [ text label, el [ Font.bold ] <| text value ]


viewNewChampionPage : Year -> NewChampionPageModel -> Element Msg
viewNewChampionPage currentYear { champion } =
    column [ spacing 10 ]
        [ el [ Font.bold, Font.size 18 ] <| text "AJOUTER CHAMPION"
        , column []
            [ viewChampionTextInput FirstName champion
            , viewChampionTextInput LastName champion
            , viewChampionTextInput Email champion
            , sportSelector False SelectedASport champion.sport
            , editProExperiences champion
            , editMedals currentYear champion
            , editYearsInFrenchTeam currentYear champion
            , Input.button [ Font.bold ] { onPress = Just PressedSaveChampionButton, label = text "Enregistrer" }
            ]
        ]


editProExperiences : ChampionForm -> Element Msg
editProExperiences { proExperiences } =
    column [ spacing 10 ]
        [ column []
            (proExperiences
                |> Dict.map
                    (\id exp ->
                        case exp of
                            ReadOnly e ->
                                viewProExperience e

                            Editable oldE newE ->
                                viewProExperienceForm id newE
                    )
                |> Dict.values
            )
        , Input.button [ Font.bold ] { onPress = Just PressedAddProExperienceButton, label = text "Ajouter une expérience" }
        ]


editMedals : Year -> ChampionForm -> Element Msg
editMedals currentYear { medals, sport } =
    column [ spacing 10 ]
        [ column []
            (medals
                |> Dict.map
                    (\id medal ->
                        case medal of
                            ReadOnly m ->
                                viewMedal m

                            Editable oldM newM ->
                                viewMedalForm currentYear id newM
                    )
                |> Dict.values
            )
        , Input.button [ Font.bold ] { onPress = Just PressedAddMedalButton, label = text "Ajouter une médaille" }
        ]


viewMedal : Medal -> Element Msg
viewMedal { competition, year, specialty, medalType } =
    column [ spacing 4 ]
        [ viewField "Compétition" (competition |> Model.competitionToDisplay)
        , viewField "Année" (year |> Model.getYear |> String.fromInt)
        , viewField "Spécialité" (specialty |> Model.specialtyToString)
        , viewField "Médaille" (medalType |> Model.medalTypeToDisplay)
        ]


editYearsInFrenchTeam : Year -> ChampionForm -> Element Msg
editYearsInFrenchTeam currentYear champion =
    column [ spacing 10 ]
        [ column []
            (champion.yearsInFrenchTeam
                |> Dict.map
                    (\id year ->
                        case year of
                            ReadOnly y ->
                                text <| String.fromInt (Model.getYear y)

                            Editable _ _ ->
                                yearSelector currentYear (SelectedAYearInFrenchTeam id)
                    )
                |> Dict.values
            )
        , row [ spacing 10 ]
            [ Input.button [ Font.bold ] { onPress = Just PressedAddYearInFrenchTeamButton, label = text "Ajouter une année" }
            ]
        ]


viewProExperienceForm : Int -> ProExperience -> Element Msg
viewProExperienceForm id newE =
    let
        fields =
            [ OccupationalCategory, Title, CompanyName, Description, Website, Contact ]
    in
    column []
        [ row [] [ el [] <| text "Expérience professionnelle", Input.button [] { onPress = Just <| PressedDeleteProExperienceButton id, label = text "Supprimer" } ]
        , column []
            (fields
                |> List.map
                    (\field ->
                        let
                            ( label, value ) =
                                getProExperienceFormFieldData field newE
                        in
                        viewTextInput label value (UpdatedProExperienceField id field)
                    )
            )
        ]


viewMedalForm : Year -> Int -> Medal -> Element Msg
viewMedalForm currentYear id newM =
    column []
        [ row [] [ el [] <| text "Médaille", Input.button [] { onPress = Just <| PressedDeleteMedalButton id, label = text "Supprimer" } ]
        , column []
            [ competitionSelector id
            , yearSelector currentYear (SelectedAMedalYear id)

            -- , specialtySelector
            ]
        ]


sportSelector : Bool -> (String -> Msg) -> Maybe Sport -> Element Msg
sportSelector showOptionAll msg currentSport =
    let
        list =
            (if showOptionAll then
                [ "Tous les sports" ]

             else
                []
            )
                ++ List.map sportToString Model.sportsList
    in
    el [] <|
        html <|
            Html.select
                [ HE.onInput msg
                , HA.style "font-family" "Roboto"
                , HA.style "font-size" "15px"
                ]
                (List.map (viewSportOption currentSport) list)


yearSelector : Year -> (String -> Msg) -> Element Msg
yearSelector currentYear msg =
    let
        list : List Int
        list =
            List.range 1960 (Model.getYear currentYear)
    in
    el [] <|
        html <|
            Html.select
                [ HE.onInput msg
                , HA.style "font-family" "Roboto"
                , HA.style "font-size" "15px"
                ]
                (list
                    |> List.map
                        (\year ->
                            Html.option
                                [ HA.value <| String.fromInt year
                                ]
                                [ Html.text <| String.fromInt year ]
                        )
                )


competitionSelector : Int -> Element Msg
competitionSelector id =
    el [] <|
        html <|
            Html.select
                [ HE.onInput <| SelectedACompetition id
                , HA.style "font-family" "Roboto"
                , HA.style "font-size" "15px"
                ]
                (Model.competitionsList
                    |> List.map
                        (\competition ->
                            Html.option
                                [ HA.value <| Model.competitionToString competition
                                ]
                                [ Html.text <| Model.competitionToDisplay competition ]
                        )
                )


viewSportOption : Maybe Sport -> String -> Html.Html msg
viewSportOption currentSport sport =
    Html.option
        [ HA.value sport
        , HA.selected <| currentSport == Model.sportFromString sport
        ]
        [ Html.text sport ]


viewChampionTextInput : FormField -> ChampionForm -> Element Msg
viewChampionTextInput field champion =
    let
        ( label, value ) =
            getChampionFormFieldData field champion
    in
    viewTextInput label value (UpdatedChampionField field)


viewTextInput : String -> String -> (String -> Msg) -> Element Msg
viewTextInput label value msg =
    Input.text
        [ Border.solid
        , Border.rounded 8
        , paddingXY 13 7
        , Border.width 3
        ]
        { onChange = msg
        , text = value
        , placeholder = Nothing
        , label =
            Input.labelAbove [ paddingEach { bottom = 4, right = 0, left = 0, top = 0 }, Font.bold ] <|
                paragraph [] [ text label ]
        }


getChampionFormFieldData : FormField -> ChampionForm -> ( String, String )
getChampionFormFieldData field champion =
    case field of
        FirstName ->
            ( "Prénom", champion.firstName )

        LastName ->
            ( "Nom", champion.lastName )

        Email ->
            ( "Email", champion.email )

        _ ->
            ( "", "" )


getProExperienceFormFieldData : FormField -> ProExperience -> ( String, String )
getProExperienceFormFieldData field exp =
    case field of
        OccupationalCategory ->
            ( "Catégorie professionnelle", exp.occupationalCategory )

        Title ->
            ( "Titre", exp.title )

        CompanyName ->
            ( "Nom de l'entreprise", exp.companyName )

        Description ->
            ( "Description", exp.description )

        Website ->
            ( "Site internet", exp.website )

        Contact ->
            ( "Contact", exp.contact )

        _ ->
            ( "", "" )


viewIf : Bool -> Element Msg -> Element Msg
viewIf condition elem =
    if condition then
        elem

    else
        none
