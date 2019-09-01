module View exposing (view)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (Document)
import Browser.Navigation as Nav
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

            NewChampionPage champion ->
                viewNewChampionPage champion


viewListPage : ListPageModel -> Element Msg
viewListPage model =
    column [ spacing 10 ]
        [ case model.champions of
            Success champions ->
                column [ spacing 20 ]
                    [ sportSelector True FilteredBySport model.sport
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
            , label = el [ Border.width 1 ] <| text <| "Retour à la liste"
            }
        , case champion of
            Success champ ->
                column [ spacing 5 ]
                    [ text <| Model.getId champ
                    , text <| champ.lastName
                    , text <| champ.firstName
                    , text <| Model.sportToString champ.sport
                    ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]


viewNewChampionPage : Champion -> Element Msg
viewNewChampionPage champion =
    column []
        ([ viewChampionTextInput FirstName champion
         , viewChampionTextInput LastName champion
         , viewChampionTextInput Email champion
         , sportSelector False UpdatedChampionSport (Just champion.sport)
         ]
            ++ (champion.proExperiences
                    |> List.map viewProExperienceForm
               )
            ++ [ Input.button [] { onPress = Just PressedAddProExperienceButton, label = text "Ajouter une expérience professionnelle" }
               , Input.button [] { onPress = Just PressedSaveChampionButton, label = text "Enregistrer" }
               ]
        )


viewProExperienceForm : ProExperience -> Element Msg
viewProExperienceForm proExperience =
    let
        fields =
            [ OccupationalCategory, Title, CompanyName, Description, Website, Contact ]
    in
    column []
        [ row [] [ el [] <| text "Expérience professionnelle", Input.button [] { onPress = Just <| PressedDeleteProExperienceButton proExperience, label = text "Supprimer" } ]
        , column []
            (fields
                |> List.map
                    (\field ->
                        let
                            ( label, value ) =
                                getProExperienceFormFieldData field proExperience
                        in
                        viewTextInput label value (UpdatedProExperienceField proExperience field)
                    )
            )
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


viewSportOption : Maybe Sport -> String -> Html.Html msg
viewSportOption currentSport sport =
    Html.option
        [ HA.value sport
        , HA.selected <| currentSport == Model.sportFromString sport
        ]
        [ Html.text sport ]


viewChampionTextInput : FormField -> Champion -> Element Msg
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


getChampionFormFieldData : FormField -> Champion -> ( String, String )
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
