module Page.EditChampion exposing (championToForm, init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Dict
import Editable exposing (Editable(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import File
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (Attachment, Champion, ChampionForm, EditChampionPageModel, FormField(..), Medal, Msg(..), ProExperience, Sport, Year)
import RemoteData exposing (RemoteData(..), WebData)
import UI
import UI.Button as Button
import UI.Color


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
    , email = Nothing
    , birthDate = Nothing
    , address = Nothing
    , phoneNumber = Nothing
    , website = Nothing
    , sport = Nothing
    , proExperiences = Dict.empty
    , yearsInFrenchTeam = Dict.empty
    , medals = Dict.empty
    , isMember = False
    , intro = Nothing
    , highlights = []
    , profilePicture = Nothing
    , frenchTeamParticipation = Nothing
    , olympicGamesParticipation = Nothing
    , worldCupParticipation = Nothing
    , trackRecord = Nothing
    , bestMemory = Nothing
    , decoration = Nothing
    , background = Nothing
    , volunteering = Nothing
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
    , birthDate = champion.birthDate
    , address = champion.address
    , phoneNumber = champion.phoneNumber
    , website = champion.website
    , sport = Just champion.sport
    , proExperiences = champion.proExperiences |> toEditableDict
    , yearsInFrenchTeam = champion.yearsInFrenchTeam |> toEditableDict
    , medals = champion.medals |> toEditableDict
    , isMember = champion.isMember
    , intro = champion.intro
    , highlights = champion.highlights
    , profilePicture = champion.profilePicture
    , frenchTeamParticipation = champion.frenchTeamParticipation
    , olympicGamesParticipation = champion.olympicGamesParticipation
    , worldCupParticipation = champion.worldCupParticipation
    , trackRecord = champion.trackRecord
    , bestMemory = champion.bestMemory
    , decoration = champion.decoration
    , background = champion.background
    , volunteering = champion.volunteering
    }


view : Year -> EditChampionPageModel -> Element Msg
view currentYear model =
    column [ UI.largeSpacing ]
        [ UI.heading 1
            (el [ Font.bold, Font.size 18 ] <|
                text
                    (if model.id == Nothing then
                        "AJOUTER CHAMPION"

                     else
                        "ÉDITER CHAMPION"
                    )
            )
        , case model.champion of
            Success champion ->
                column [ UI.defaultSpacing ]
                    [ row [ UI.largeSpacing ]
                        [ viewProfilePicture champion.profilePicture
                        , column [ UI.defaultSpacing ]
                            [ viewChampionTextInput FirstName champion
                            , viewChampionTextInput LastName champion
                            , viewChampionTextInput Email champion
                            ]
                        ]
                    , Common.sportSelector False champion.sport
                    , let
                        ( label, value ) =
                            getChampionFormFieldData Intro champion
                      in
                      viewTextArea label value (UpdatedChampionField Intro)
                    , editProExperiences champion
                    , editMedals currentYear champion
                    , editYearsInFrenchTeam currentYear champion
                    , text "Enregistrer"
                        |> Button.makeButton (Just PressedSaveChampionButton)
                        |> Button.withBackgroundColor UI.Color.green
                        |> Button.withAttrs [ htmlAttribute <| HA.id "save-champion-btn" ]
                        |> Button.viewButton
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
        , text "Ajouter une expérience"
            |> Button.makeButton (Just PressedAddProExperienceButton)
            |> Button.withBackgroundColor UI.Color.grey
            |> Button.viewButton
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
        , text "Ajouter une médaille"
            |> Button.makeButton (Just PressedAddMedalButton)
            |> Button.withBackgroundColor UI.Color.grey
            |> Button.viewButton
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
        , text "Ajouter une année"
            |> Button.makeButton (Just PressedAddYearInFrenchTeamButton)
            |> Button.withBackgroundColor UI.Color.grey
            |> Button.viewButton
        ]


viewProExperienceForm : Int -> ProExperience -> Element Msg
viewProExperienceForm id newE =
    let
        fields =
            [ Title, CompanyName, Description, Website, Contact ]
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
                        UI.textInput []
                            { onChange = UpdatedProExperienceField id field
                            , text = value
                            , placeholder = Nothing
                            , label = Just label
                            }
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
                , HA.style "font-family" "Open Sans"
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
    UI.textInput []
        { onChange = UpdatedChampionField field
        , text = value
        , placeholder = Nothing
        , label = Just label
        }


viewTextArea : String -> String -> (String -> Msg) -> Element Msg
viewTextArea label value msg =
    Input.multiline
        [ Border.solid
        , Border.rounded 8
        , paddingXY 13 7
        , Border.width 1
        , width <| px 400
        ]
        { onChange = msg
        , text = value
        , placeholder = Nothing
        , label =
            Input.labelAbove [ paddingEach { bottom = 4, right = 0, left = 0, top = 0 }, Font.bold ] <|
                paragraph [] [ text label ]
        , spellcheck = False
        }


getChampionFormFieldData : FormField -> ChampionForm -> ( String, String )
getChampionFormFieldData field champion =
    case field of
        FirstName ->
            ( "Prénom", champion.firstName )

        LastName ->
            ( "Nom", champion.lastName )

        Email ->
            ( "Email", champion.email |> Maybe.withDefault "" )

        Intro ->
            ( "Intro", champion.intro |> Maybe.withDefault "" )

        _ ->
            ( "", "" )


getProExperienceFormFieldData : FormField -> ProExperience -> ( String, String )
getProExperienceFormFieldData field exp =
    case field of
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


viewProfilePicture : Maybe Attachment -> Element Msg
viewProfilePicture profilePicture =
    el [ width <| px 200 ] <|
        case profilePicture of
            Nothing ->
                el [ width fill ] <|
                    column [ spacing 10, padding 10, centerX ]
                        [ Input.button
                            [ Background.color UI.Color.green
                            , padding 10
                            , Border.rounded 5
                            , Font.color UI.Color.white
                            , width fill
                            , Font.center
                            ]
                            { onPress = Just BeganFileSelection
                            , label = text "Uploader une photo"
                            }
                        ]

            Just { filename, base64 } ->
                case base64 of
                    Nothing ->
                        row [ spacing 10 ]
                            [ el [] <| text "Récupération du fichier en cours..."
                            , Input.button
                                [ Border.rounded 3
                                , padding 10
                                , Background.color UI.Color.red
                                , Font.color UI.Color.white
                                ]
                                { onPress = Just CancelledFileSelection
                                , label = text "Annuler"
                                }
                            ]

                    Just url ->
                        image [ width <| px 200 ] { src = url, description = "Photo de profil" }
