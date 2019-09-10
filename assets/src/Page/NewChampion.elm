module Page.NewChampion exposing (view)

import Common
import Dict
import Editable exposing (Editable(..))
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Model exposing (ChampionForm, FormField(..), Medal, Msg(..), NewChampionPageModel, ProExperience, Sport, Year)
import RemoteData exposing (RemoteData(..), WebData)


view : Year -> NewChampionPageModel -> Element Msg
view currentYear { champion } =
    column [ spacing 10 ]
        [ el [ Font.bold, Font.size 18 ] <| text "AJOUTER CHAMPION"
        , column []
            [ viewChampionTextInput FirstName champion
            , viewChampionTextInput LastName champion
            , viewChampionTextInput Email champion
            , Common.sportSelector False champion.sport
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
                                Common.viewProExperience e

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
                                Common.viewMedal m

                            Editable _ newM ->
                                viewMedalForm currentYear id sport newM
                    )
                |> Dict.values
            )
        , Input.button [ Font.bold ] { onPress = Just PressedAddMedalButton, label = text "Ajouter une médaille" }
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


viewMedalForm : Year -> Int -> Maybe Sport -> Medal -> Element Msg
viewMedalForm currentYear id sport medal =
    column []
        [ row [] [ el [] <| text "Médaille", Input.button [] { onPress = Just <| PressedDeleteMedalButton id, label = text "Supprimer" } ]
        , column []
            [ competitionSelector id
            , yearSelector currentYear (SelectedAMedalYear id)
            , Common.specialtySelector False sport (SelectedAMedalSpecialty id)
            ]
        ]


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
