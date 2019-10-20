module Page.EditChampion exposing (championToForm, init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Dict exposing (Dict)
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
import Model exposing (Attachment, Champion, ChampionForm, EditChampionPageModel, FormField(..), Medal, MedalType(..), Msg(..), Picture, ProExperience, Sectors, Sport, Year)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI
import UI.Button as Button
import UI.Color as Color


init : Maybe Id -> ( EditChampionPageModel, Cmd Msg )
init maybeId =
    case maybeId of
        Just id ->
            ( { id = Just id
              , champion = Loading
              , sectorDropdown = Dropdown.init
              , medalsTableState = Table.initialSort "ANNÉE"
              }
            , Api.getChampion True id
            )

        Nothing ->
            ( { id = Nothing
              , champion = Success initChampionForm
              , sectorDropdown = Dropdown.init
              , medalsTableState = Table.initialSort "ANNÉE"
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
    , pictures = []
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
    , pictures = champion.pictures
    }


view : RemoteData (Graphql.Http.Error Sectors) Sectors -> Year -> EditChampionPageModel -> Element Msg
view rdSectors currentYear model =
    column [ UI.largeSpacing, width fill ]
        [ UI.heading 1
            (el [ Font.bold, UI.fontSize 6 ] <|
                text
                    (if model.id == Nothing then
                        "AJOUTER UN CHAMPION"

                     else
                        "ÉDITER LA FICHE CHAMPION"
                    )
            )
        , case ( model.champion, rdSectors ) of
            ( Success champion, Success sectors ) ->
                column [ UI.largeSpacing, width fill ]
                    [ viewButtons
                    , row [ UI.largeSpacing ]
                        [ viewProfilePicture champion.profilePicture
                        , column [ UI.defaultSpacing, width fill ]
                            [ viewChampionTextInput FirstName champion
                            , viewChampionTextInput LastName champion
                            ]
                        ]
                    , Common.sportSelector False champion.sport
                    , let
                        ( label, value ) =
                            getChampionFormFieldData Intro champion
                      in
                      viewTextArea label value (UpdatedChampionField Intro)
                    , editHighlights champion
                    , editPrivateInfo champion
                    , editSportCareer champion
                    , editProfessionalCareer sectors model.sectorDropdown champion
                    , editPictures champion
                    , editMedals currentYear model.medalsTableState champion
                    , editYearsInFrenchTeam currentYear champion
                    , viewButtons
                    ]

            _ ->
                text "..."
        ]


editPrivateInfo : ChampionForm -> Element Msg
editPrivateInfo champion =
    Common.viewBlock "Informations privées"
        [ viewChampionTextInput BirthDate champion
        , viewChampionTextInput Address champion
        , row [ UI.defaultSpacing, width fill ]
            [ viewChampionTextInput Email champion
            , viewChampionTextInput PhoneNumber champion
            ]
        ]


editSportCareer : ChampionForm -> Element Msg
editSportCareer champion =
    Common.viewBlock "Carrière sportive"
        [ viewChampionTextInput FrenchTeamParticipation champion
        , viewChampionTextInput OlympicGamesParticipation champion
        , viewChampionTextInput WorldCupParticipation champion
        , viewChampionTextInput TrackRecord champion
        , viewChampionTextInput BestMemory champion
        , viewChampionTextInput Decoration champion
        ]


editProfessionalCareer : Sectors -> Dropdown.Model -> ChampionForm -> Element Msg
editProfessionalCareer sectors sectorDropdown champion =
    Common.viewBlock "Carrière professionnelle"
        [ viewChampionTextInput Background champion
        , viewChampionTextInput Volunteering champion
        , column [ UI.defaultSpacing, width fill ]
            [ row [ UI.defaultSpacing ]
                [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Expériences professionnelles"
                , (el [ htmlAttribute <| HA.title "Ajouter une expérience", Font.color Color.green, UI.largestFont ] <| UI.viewIcon "plus-circle")
                    |> Button.makeButton (Just PressedAddProExperienceButton)
                    |> Button.withPadding (padding 0)
                    |> Button.viewButton
                ]
            , editProExperiences sectors sectorDropdown champion
            ]
        ]


editProExperiences : Sectors -> Dropdown.Model -> ChampionForm -> Element Msg
editProExperiences sectors sectorDropdown { proExperiences } =
    column [ UI.defaultSpacing, width fill ]
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


editPictures : ChampionForm -> Element Msg
editPictures champion =
    let
        id =
            Model.getId champion
    in
    Common.viewBlock "Photos"
        [ row [ width fill, clipX, scrollbarX, UI.defaultSpacing ]
            (champion.pictures |> List.map (editPicture id))
        , text "Ajouter une photo"
            |> Button.makeButton (Just PressedAddPictureButton)
            |> Button.withBackgroundColor Color.grey
            |> Button.viewButton
        ]


editPicture : String -> Picture -> Element Msg
editPicture championId { id, attachment } =
    let
        { filename, base64 } =
            attachment
    in
    if filename == "" then
        el [] <|
            column [ spacing 10, padding 10, centerX ]
                [ text "Uploader une photo"
                    |> Button.makeButton (Just <| BeganFileSelection id)
                    |> Button.withBackgroundColor Color.green
                    |> Button.viewButton
                ]

    else
        column [ UI.defaultSpacing ]
            [ let
                src =
                    base64 |> Maybe.withDefault (Model.baseEndpoint ++ "/uploads/" ++ championId ++ "/" ++ filename)
              in
              image [ width <| px 200 ] { src = src, description = "Photo de profil" }
            , el [ centerX ]
                (text "Changer la photo"
                    |> Button.makeButton (Just <| BeganFileSelection id)
                    |> Button.withBackgroundColor Color.green
                    |> Button.viewButton
                )
            ]


editMedals : Year -> Table.State -> ChampionForm -> Element Msg
editMedals currentYear tableState { medals, sport } =
    Common.viewBlock "Palmarès"
        [ column [ width fill ]
            [ (el [ htmlAttribute <| HA.title "Ajouter une médaille", Font.color Color.green, UI.largestFont ] <| UI.viewIcon "plus-circle")
                |> Button.makeButton (Just PressedAddMedalButton)
                |> Button.withPadding (padding 0)
                |> Button.viewButton
            , medals
                |> Dict.toList
                |> Table.view (tableConfig sport currentYear) tableState
                |> html
                |> el [ htmlAttribute <| HA.id "edit-champion-medals-list", width fill ]
            ]
        ]


tableConfig : Maybe Sport -> Year -> Table.Config ( Int, Editable Medal ) Msg
tableConfig sport currentYear =
    let
        tableCustomizations =
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = Tuple.second >> Editable.value >> Model.getId
        , toMsg = TableMsg
        , columns = tableColumns sport currentYear
        , customizations = { tableCustomizations | rowAttrs = always [] }
        }


attrsForHeaders : Dict String (List (Html.Attribute msg))
attrsForHeaders =
    Dict.fromList <|
        [ ( "MÉDAILLE", [ HA.style "text-align" "center" ] )
        , ( "ANNÉE", [ HA.style "text-align" "center" ] )
        ]


tableColumns : Maybe Sport -> Year -> List (Table.Column ( Int, Editable Medal ) Msg)
tableColumns sport currentYear =
    [ Table.veryCustomColumn
        { name = "MÉDAILLE"
        , viewData =
            \( id, editableMedal ) ->
                let
                    medal =
                        Editable.value editableMedal
                in
                Common.centeredCell [] (Common.medalIconHtml medal)
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "TYPE"
        , viewData =
            \( id, editableMedal ) ->
                Common.defaultCell []
                    (case editableMedal of
                        ReadOnly medal ->
                            Html.text <| Model.medalTypeToDisplay medal.medalType

                        Editable _ newM ->
                            UI.defaultLayoutForTable <| medalTypeSelector id newM.medalType
                    )
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "COMPÉTITION"
        , viewData =
            \( id, editableMedal ) ->
                Common.defaultCell []
                    (case editableMedal of
                        ReadOnly medal ->
                            Html.text <| Model.competitionToDisplay medal.competition

                        Editable _ newM ->
                            UI.defaultLayoutForTable <| Common.competitionSelector False (SelectedAMedalCompetition id) (Just newM.competition)
                    )
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData =
            \( id, editableMedal ) ->
                Common.defaultCell []
                    (case editableMedal of
                        ReadOnly medal ->
                            Html.text <| Model.specialtyToDisplay medal.specialty

                        Editable _ newM ->
                            UI.defaultLayoutForTable <| Common.specialtySelector False sport (SelectedAMedalSpecialty id) (Just newM.specialty)
                    )
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "ANNÉE"
        , viewData =
            \( id, editableMedal ) ->
                Common.centeredCell []
                    (case editableMedal of
                        ReadOnly medal ->
                            Html.text <| String.fromInt <| Model.getYear medal.year

                        Editable _ newM ->
                            UI.defaultLayoutForTable <| Common.yearSelector False currentYear (SelectedAMedalYear id) (Just newM.year)
                    )
        , sorter = Table.decreasingOrIncreasingBy (\( _, editableMedal ) -> editableMedal |> Editable.value |> .year |> Model.getYear)
        }
    , Table.veryCustomColumn
        { name = ""
        , viewData =
            \( id, _ ) ->
                Common.centeredCell
                    [ HA.style "color" <| Color.colorToString Color.green ]
                    (Html.i [ HA.class <| "zmdi zmdi-edit", HA.style "cursor" "pointer", HA.title "Modifier", HE.onClick <| PressedEditMedalButton id ] [])
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = ""
        , viewData =
            \( id, _ ) ->
                Common.centeredCell
                    [ HA.style "color" <| Color.colorToString Color.red ]
                    (Html.i [ HA.class <| "zmdi zmdi-close", HA.style "cursor" "pointer", HA.title "Supprimer", HE.onClick <| PressedDeleteMedalButton id ] [])
        , sorter = Table.unsortable
        }
    ]


editYearsInFrenchTeam : Year -> ChampionForm -> Element Msg
editYearsInFrenchTeam currentYear champion =
    Common.viewBlock "Années en équipe de France"
        [ column [ UI.largeSpacing ]
            [ column [ UI.defaultSpacing ]
                (champion.yearsInFrenchTeam
                    |> Dict.map
                        (\id year ->
                            row [ UI.defaultSpacing ]
                                [ case year of
                                    ReadOnly y ->
                                        text <| String.fromInt (Model.getYear y)

                                    Editable _ newY ->
                                        Common.yearSelector False currentYear (SelectedAYearInFrenchTeam id) (Just newY)
                                , (el [ htmlAttribute <| HA.title "Supprimer", Font.color Color.red, UI.largeFont ] <| UI.viewIcon "close")
                                    |> Button.makeButton (Just <| PressedDeleteYearInFrenchTeamButton id)
                                    |> Button.withPadding (padding 0)
                                    |> Button.viewButton
                                ]
                        )
                    |> Dict.values
                )
            , (el [ htmlAttribute <| HA.title "Ajouter une année", Font.color Color.green, UI.largestFont ] <| UI.viewIcon "plus-circle")
                |> Button.makeButton (Just PressedAddYearInFrenchTeamButton)
                |> Button.withPadding (padding 0)
                |> Button.viewButton
            ]
        ]


viewProExperienceForm : Sectors -> Dropdown.Model -> Int -> ProExperience -> Element Msg
viewProExperienceForm sectors sectorDropdown id newE =
    column [ width fill ]
        [ row [ UI.defaultSpacing ]
            [ el [] <| text "Expérience professionnelle"
            , Input.button []
                { onPress = Just <| PressedDeleteProExperienceButton id
                , label = el [ htmlAttribute <| HA.title "Supprimer", Font.color Color.red, UI.largeFont ] <| UI.viewIcon "close"
                }
            ]
        , column [ UI.defaultSpacing, width fill ]
            [ viewSectorDropdown sectors sectorDropdown newE
            , row [ UI.defaultSpacing, width fill ]
                [ viewProExperienceTextInput id Title newE
                , viewProExperienceTextInput id CompanyName newE
                ]
            , viewProExperienceTextInput id Description newE
            , row [ UI.defaultSpacing, width fill ]
                [ viewProExperienceTextInput id Website newE
                , viewProExperienceTextInput id Contact newE
                ]
            ]
        ]


viewProExperienceTextInput : Int -> FormField -> ProExperience -> Element Msg
viewProExperienceTextInput id field exp =
    let
        ( label, value ) =
            getProExperienceFormFieldData field exp
    in
    UI.textInput [ width fill ]
        { onChange = UpdatedProExperienceField id field
        , text = value
        , placeholder = Nothing
        , label = Just label
        }


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
            , displayFn = \data -> el [ UI.defaultPadding, UI.mediumFont, Font.color Color.darkerGrey ] <| text data
            , header = Nothing
            , placeholder = Just <| Input.placeholder [ Font.italic ] <| text "Rechercher..."
            , inputAttrs = []
            }
    in
    Dropdown.viewDropdownInput config sectorDropdown list


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
        , width fill
        , height <| minimum 80 fill
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

        Intro ->
            ( "Intro", champion.intro |> Maybe.withDefault "" )

        FrenchTeamParticipation ->
            ( "Années en équipe de France", champion.frenchTeamParticipation |> Maybe.withDefault "" )

        OlympicGamesParticipation ->
            ( "Participation aux JO", champion.olympicGamesParticipation |> Maybe.withDefault "" )

        WorldCupParticipation ->
            ( "Championnats du monde", champion.worldCupParticipation |> Maybe.withDefault "" )

        TrackRecord ->
            ( "Palmarès", champion.trackRecord |> Maybe.withDefault "" )

        BestMemory ->
            ( "Ton meilleur souvenir", champion.bestMemory |> Maybe.withDefault "" )

        Decoration ->
            ( "Décoration", champion.decoration |> Maybe.withDefault "" )

        Background ->
            ( "Formation", champion.background |> Maybe.withDefault "" )

        Volunteering ->
            ( "Bénévolat", champion.volunteering |> Maybe.withDefault "" )

        BirthDate ->
            ( "Date de naissance", champion.birthDate |> Maybe.withDefault "" )

        Address ->
            ( "Adresse", champion.address |> Maybe.withDefault "" )

        Email ->
            ( "Adresse e-mail", champion.email |> Maybe.withDefault "" )

        PhoneNumber ->
            ( "N° de téléphone", champion.phoneNumber |> Maybe.withDefault "" )

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
                            |> Button.makeButton (Just <| BeganFileSelection (Id "0"))
                            |> Button.withBackgroundColor Color.green
                            |> Button.viewButton
                        ]

            Just { filename, base64 } ->
                column [ UI.defaultSpacing, width fill ]
                    [ let
                        src =
                            base64 |> Maybe.withDefault (Model.baseEndpoint ++ "/uploads/" ++ filename)
                      in
                      image [ width <| px 200 ] { src = src, description = "Photo de profil" }
                    , el [ centerX ]
                        (text "Changer la photo"
                            |> Button.makeButton (Just <| BeganFileSelection (Id "0"))
                            |> Button.withBackgroundColor Color.green
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
                                        |> Button.withBackgroundColor Color.grey
                                        |> Button.viewButton
                                    , text "Supprimer"
                                        |> Button.makeButton (Just <| PressedDeleteHighlightButton id)
                                        |> Button.withBackgroundColor Color.red
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
                                        |> Button.withBackgroundColor Color.green
                                        |> Button.viewButton
                                    , text "Annuler"
                                        |> Button.makeButton (Just <| CancelledHighlightEdition id)
                                        |> Button.withBackgroundColor Color.grey
                                        |> Button.viewButton
                                    ]
                            )
                    )
                |> Dict.values
            )
        , text "Ajouter un fait marquant"
            |> Button.makeButton (Just PressedAddHighlightButton)
            |> Button.withBackgroundColor Color.grey
            |> Button.viewButton
        ]


viewButtons : Element Msg
viewButtons =
    row [ width fill, spaceEvenly ]
        [ text "Annuler"
            |> Button.makeButton (Just GoBack)
            |> Button.withBackgroundColor Color.lighterGrey
            |> Button.viewButton
        , text "Enregistrer les modifications"
            |> Button.makeButton (Just PressedSaveChampionButton)
            |> Button.withBackgroundColor Color.green
            |> Button.withAttrs [ htmlAttribute <| HA.id "save-champion-btn" ]
            |> Button.viewButton
        ]


medalTypeSelector : Int -> MedalType -> Element Msg
medalTypeSelector index currentMedalType =
    el [] <|
        html <|
            Html.select
                [ HE.on "change" <| D.map (SelectedAMedalType index) <| HE.targetValue
                , HA.style "font-family" "Open Sans"
                , HA.style "font-size" "15px"
                ]
                ([ Gold, Silver, Bronze ]
                    |> List.map
                        (\medalType ->
                            Html.option
                                [ HA.value <| String.fromInt <| Model.medalTypeToInt medalType
                                , HA.selected (currentMedalType == medalType)
                                ]
                                [ Html.text <| Model.medalTypeToDisplay medalType ]
                        )
                )
