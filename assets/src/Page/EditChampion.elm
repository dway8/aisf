module Page.EditChampion exposing (championToForm, init, view)

import Aisf.Scalar exposing (Id(..))
import Api
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
import Json.Decode as D
import Model exposing (Champion, ChampionForm, EditChampionPageModel, FormField(..), Medal, Msg(..), ProExperience, Sport, Year)
import RemoteData exposing (RemoteData(..), WebData)


init : Maybe Id -> ( EditChampionPageModel, Cmd Msg )
init maybeId =
    case maybeId of
        Just id ->
            ( { id = Just id, champion = Loading }
            , Api.getChampion id
            )

        Nothing ->
            ( { id = Nothing, champion = Success initChampionForm }
            , Cmd.none
            )


initChampionForm : ChampionForm
initChampionForm =
    { id = Id "new"
    , lastName = ""
    , firstName = ""
    , email = ""
    , sport = Nothing
    , proExperiences = Dict.empty
    , yearsInFrenchTeam = Dict.empty
    , medals = Dict.empty
    , isMember = False
    }


championToForm : Champion -> ChampionForm
championToForm champion =
    let
        toEditableDict =
            List.map Editable.ReadOnly >> List.indexedMap Tuple.pair >> Dict.fromList
    in
    { id = champion.id
    , lastName = champion.lastName
    , firstName = champion.firstName
    , email = champion.email
    , sport = Just champion.sport
    , proExperiences = champion.proExperiences |> toEditableDict
    , yearsInFrenchTeam = champion.yearsInFrenchTeam |> toEditableDict
    , medals = champion.medals |> toEditableDict
    , isMember = champion.isMember
    }


view : Year -> EditChampionPageModel -> Element Msg
view currentYear model =
    column [ spacing 20 ]
        [ el [ Font.bold, Font.size 18 ] <|
            text
                (if model.id == Nothing then
                    "AJOUTER CHAMPION"

                 else
                    "ÉDITER CHAMPION"
                )
        , case model.champion of
            Success champion ->
                column [ spacing 10 ]
                    [ viewChampionTextInput FirstName champion
                    , viewChampionTextInput LastName champion
                    , viewChampionTextInput Email champion
                    , Common.sportSelector False champion.sport
                    , editProExperiences champion
                    , editMedals currentYear champion
                    , editYearsInFrenchTeam currentYear champion
                    , Input.button [ Font.bold ] { onPress = Just PressedSaveChampionButton, label = text "Enregistrer" }
                    ]

            _ ->
                text "..."
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
                                column [ spacing 5 ]
                                    [ Input.button [ Font.bold ] { onPress = Just <| PressedEditProExperienceButton id, label = text "Éditer" }
                                    , Common.viewProExperience e
                                    ]

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
                                column [ spacing 5 ]
                                    [ Input.button [ Font.bold ] { onPress = Just <| PressedEditMedalButton id, label = text "Éditer" }
                                    , Common.viewMedal m
                                    ]

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
                                Common.yearSelector False currentYear (SelectedAYearInFrenchTeam id)
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
            , Common.yearSelector False currentYear (SelectedAMedalYear id)
            , Common.specialtySelector False sport (SelectedAMedalSpecialty id)
            ]
        ]


competitionSelector : Int -> Element Msg
competitionSelector id =
    el [] <|
        html <|
            Html.select
                [ HE.on "change" <| D.map (SelectedACompetition id) <| HE.targetValue
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
