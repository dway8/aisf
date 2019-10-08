module Page.EditChampion exposing (championToForm, init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Dict
import Dropdown
import Editable exposing (Editable(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import File
import Graphql.Http
import Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (Attachment, Champion, ChampionForm, EditChampionPageModel, FormField(..), Medal, Msg(..), ProExperience, Sectors, Sport, Year)
import RemoteData exposing (RemoteData(..), WebData)
import UI
import UI.Button as Button
import UI.Color


init : Maybe Id -> ( EditChampionPageModel, Cmd Msg )
init maybeId =
    case maybeId of
        Just id ->
            ( { id = Just id
              , champion = Loading
              , sectorDropdown = Dropdown.init
              }
            , Api.getChampion id
            )

        Nothing ->
            ( { id = Nothing
              , champion = Success initChampionForm
              , sectorDropdown = Dropdown.init
              }
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
    , highlights = Dict.empty
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
    , highlights = champion.highlights |> toEditableDict
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


view : RemoteData (Graphql.Http.Error Sectors) Sectors -> Year -> EditChampionPageModel -> Element Msg
view rdSectors currentYear model =
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
        , case ( model.champion, rdSectors ) of
            ( Success champion, Success sectors ) ->
                column [ UI.largeSpacing ]
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
                    , editHighlights champion
                    , editProExperiences sectors model.sectorDropdown champion
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


editProExperiences : Sectors -> Dropdown.Model -> ChampionForm -> Element Msg
editProExperiences sectors sectorDropdown { proExperiences } =
    column [ UI.largeSpacing ]
        [ column [ UI.defaultSpacing ]
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
                                viewProExperienceForm sectors sectorDropdown id newE
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
    column [ UI.largeSpacing ]
        [ column [ UI.defaultSpacing ]
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
    column [ UI.largeSpacing ]
        [ column [ UI.defaultSpacing ]
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


viewProExperienceForm : Sectors -> Dropdown.Model -> Int -> ProExperience -> Element Msg
viewProExperienceForm sectors sectorDropdown id newE =
    let
        fields =
            [ Title, CompanyName, Description, Website, Contact ]
    in
    column []
        [ row [] [ el [] <| text "Expérience professionnelle", Input.button [] { onPress = Just <| PressedDeleteProExperienceButton id, label = text "Supprimer" } ]
        , column [ UI.defaultSpacing ]
            (viewSectorDropdown sectors sectorDropdown newE
                :: (fields
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
            )
        ]


viewSectorDropdown : Sectors -> Dropdown.Model -> ProExperience -> Element Msg
viewSectorDropdown sectors sectorDropdown proExperience =
    let
        list =
            Model.acceptableSectors sectorDropdown.query sectors

        config =
            { label = Just "Secteur d'activité"
            , msgs =
                { inputMsg = UpdatedDropdownQuery
                , mappingMsg = DropdownStateChanged
                , focusMsg = DropdownGotFocus
                , blurMsg = DropdownLostFocus
                , escapeMsg = ClosedDropdown
                , noOp = NoOp
                , removeMsg = RemovedItemFromDropdown
                }
            , displayFn = \data -> el [ UI.defaultPadding, UI.mediumFont ] <| text data
            , header = Nothing
            , placeholder = Just <| Input.placeholder [] <| text "Rechercher..."
            , inputAttrs = []
            }
    in
    Dropdown.viewDropdownInput config sectorDropdown list


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
            ( "Titre", exp.title |> Maybe.withDefault "" )

        CompanyName ->
            ( "Nom de l'entreprise", exp.companyName |> Maybe.withDefault "" )

        Description ->
            ( "Description", exp.description |> Maybe.withDefault "" )

        Website ->
            ( "Site internet", exp.website |> Maybe.withDefault "" )

        Contact ->
            ( "Contact", exp.contact |> Maybe.withDefault "" )

        _ ->
            ( "", "" )


viewProfilePicture : Maybe Attachment -> Element Msg
viewProfilePicture profilePicture =
    el [ width <| px 200 ] <|
        case profilePicture of
            Nothing ->
                el [ width fill ] <|
                    column [ spacing 10, padding 10, centerX ]
                        [ text "Uploader une photo"
                            |> Button.makeButton (Just BeganFileSelection)
                            |> Button.withBackgroundColor UI.Color.green
                            |> Button.viewButton
                        ]

            Just { filename, base64 } ->
                column [ UI.defaultSpacing, width fill ]
                    [ let
                        src =
                            base64 |> Maybe.withDefault ("/uploads/" ++ filename)
                      in
                      image [ width <| px 200 ] { src = src, description = "Photo de profil" }
                    , el [ centerX ]
                        (text "Changer la photo"
                            |> Button.makeButton (Just BeganFileSelection)
                            |> Button.withBackgroundColor UI.Color.green
                            |> Button.viewButton
                        )
                    ]


editHighlights : ChampionForm -> Element Msg
editHighlights { highlights } =
    column [ UI.largeSpacing ]
        [ el [ Font.bold ] <| text "Faits marquants"
        , column [ UI.defaultSpacing ]
            (highlights
                |> Dict.map
                    (\id highlight ->
                        row [ UI.defaultSpacing ]
                            (case highlight of
                                ReadOnly h ->
                                    [ text h
                                    , text "Éditer"
                                        |> Button.makeButton
                                            (Just <| PressedEditHighlightButton id)
                                        |> Button.withBackgroundColor UI.Color.grey
                                        |> Button.viewButton
                                    , text "Supprimer"
                                        |> Button.makeButton (Just <| PressedDeleteHighlightButton id)
                                        |> Button.withBackgroundColor UI.Color.red
                                        |> Button.viewButton
                                    ]

                                Editable _ newH ->
                                    [ UI.textInput []
                                        { onChange = UpdatedHighlight id
                                        , text = newH
                                        , placeholder = Nothing
                                        , label = Nothing
                                        }
                                    , text "OK"
                                        |> Button.makeButton (Just <| PressedConfirmHighlightButton id)
                                        |> Button.withBackgroundColor UI.Color.green
                                        |> Button.viewButton
                                    , text "Annuler"
                                        |> Button.makeButton (Just <| CancelledHighlightEdition id)
                                        |> Button.withBackgroundColor UI.Color.grey
                                        |> Button.viewButton
                                    ]
                            )
                    )
                |> Dict.values
            )
        , text "Ajouter un fait marquant"
            |> Button.makeButton (Just PressedAddHighlightButton)
            |> Button.withBackgroundColor UI.Color.grey
            |> Button.viewButton
        ]
