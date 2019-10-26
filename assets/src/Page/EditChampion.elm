module Page.EditChampion exposing (championToForm, init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Dict exposing (Dict)
import Dropdown
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
import Model exposing (Attachment, Champion, ChampionForm, EditChampionPageModel, FormField(..), Medal, MedalType(..), Msg(..), Picture, ProExperience, Sectors, Sport(..), Year)
import RemoteData exposing (RemoteData(..), WebData)
import Route
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


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
    , sport = SkiAlpin
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
    , pictures = Dict.empty
    }


championToForm : Champion -> ChampionForm
championToForm champion =
    let
        toDict =
            List.indexedMap Tuple.pair >> Dict.fromList
    in
    { id = champion.id
    , lastName = champion.lastName
    , firstName = champion.firstName
    , email = champion.email
    , birthDate = champion.birthDate
    , address = champion.address
    , phoneNumber = champion.phoneNumber
    , website = champion.website
    , sport = champion.sport
    , proExperiences = champion.proExperiences |> toDict
    , yearsInFrenchTeam = champion.yearsInFrenchTeam |> toDict
    , medals = champion.medals |> toDict
    , isMember = champion.isMember
    , intro = champion.intro
    , highlights = champion.highlights |> toDict
    , profilePicture = champion.profilePicture
    , frenchTeamParticipation = champion.frenchTeamParticipation
    , olympicGamesParticipation = champion.olympicGamesParticipation
    , worldCupParticipation = champion.worldCupParticipation
    , trackRecord = champion.trackRecord
    , bestMemory = champion.bestMemory
    , decoration = champion.decoration
    , background = champion.background
    , volunteering = champion.volunteering
    , pictures = champion.pictures |> toDict
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
                    , row [ UI.largeSpacing, width <| px 600 ]
                        [ viewProfilePicture champion.profilePicture
                        , column [ UI.defaultSpacing, width fill ]
                            [ viewChampionTextInput FirstName champion
                            , viewChampionTextInput LastName champion
                            ]
                        ]
                    , row [ UI.largerSpacing ]
                        [ row [ UI.defaultSpacing ] [ el [ Font.bold ] <| text "Discipline", Common.sportSelector False (Just champion.sport) ]
                        , memberCheckbox champion.isMember
                        ]
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


memberCheckbox : Bool -> Element Msg
memberCheckbox isMember =
    el [] <|
        Input.checkbox []
            { onChange = CheckedIsMember
            , icon = Input.defaultCheckbox
            , checked = isMember
            , label =
                Input.labelRight []
                    (text "Membre AISF")
            }


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
        , column [ UI.defaultSpacing, width fill, paddingEach { top = 10, bottom = 0, right = 0, left = 0 } ]
            [ row [ UI.defaultSpacing ]
                [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Expériences professionnelles"
                ]
            , editProExperiences sectors sectorDropdown champion
            , viewAddButton "Ajouter une expérience" PressedAddProExperienceButton
            ]
        ]


editProExperiences : Sectors -> Dropdown.Model -> ChampionForm -> Element Msg
editProExperiences sectors sectorDropdown { proExperiences } =
    column [ UI.defaultSpacing, width fill ]
        (proExperiences
            |> Dict.map
                (\id exp ->
                    column [ UI.defaultSpacing, width fill, Background.color Color.lightestGrey, UI.largePadding ]
                        [ viewSectorDropdown sectors sectorDropdown exp
                        , row [ UI.defaultSpacing, width fill ]
                            [ viewProExperienceTextInput id Title exp
                            , viewProExperienceTextInput id CompanyName exp
                            ]
                        , viewProExperienceTextInput id Description exp
                        , row [ UI.defaultSpacing, width fill ]
                            [ viewProExperienceTextInput id Website exp
                            , viewProExperienceTextInput id Contact exp
                            ]
                        , el [ alignRight ] <| viewDeleteButton (PressedDeleteProExperienceButton id)
                        ]
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
        [ Utils.viewIf (Dict.size champion.pictures > 0) <|
            row [ width fill, clipX, scrollbarX, UI.defaultSpacing ]
                (champion.pictures
                    |> Dict.map (editPicture id)
                    |> Dict.values
                )
        , viewAddButton "Ajouter une photo" PressedAddPictureButton
        ]


editPicture : String -> Int -> Picture -> Element Msg
editPicture championId id { attachment } =
    let
        { filename, base64 } =
            attachment
    in
    column [ UI.defaultSpacing ]
        [ let
            src =
                base64 |> Maybe.withDefault (Route.baseEndpoint ++ "/uploads/" ++ championId ++ "/" ++ filename)
          in
          image [ width <| px 200 ] { src = src, description = "Photo de profil" }
        , el [ centerX ] (viewDeleteButton (PressedDeletePictureButton id))
        ]


editMedals : Year -> Table.State -> ChampionForm -> Element Msg
editMedals currentYear tableState { medals, sport } =
    Common.viewBlock "Palmarès"
        [ column [ width fill ]
            [ medals
                |> Dict.toList
                |> Table.view (tableConfig sport currentYear) tableState
                |> html
                |> el [ htmlAttribute <| HA.id "edit-champion-medals-list", width fill ]
            , viewAddButton "Ajouter une médaille" PressedAddMedalButton
            ]
        ]


tableConfig : Sport -> Year -> Table.Config ( Int, Medal ) Msg
tableConfig sport currentYear =
    let
        tableCustomizations =
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = Tuple.second >> Model.getId
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


tableColumns : Sport -> Year -> List (Table.Column ( Int, Medal ) Msg)
tableColumns sport currentYear =
    [ Table.veryCustomColumn
        { name = "MÉDAILLE"
        , viewData = \( id, medal ) -> Common.centeredCell [] (Common.medalIconHtml medal)
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "TYPE"
        , viewData = \( id, medal ) -> Common.defaultCell [] (UI.defaultLayoutForTable <| el [ centerY ] <| medalTypeSelector id medal.medalType)
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "COMPÉTITION"
        , viewData =
            \( id, medal ) ->
                Common.defaultCell []
                    (UI.defaultLayoutForTable <| el [ centerY ] <| Common.competitionSelector False Model.competitionsList (SelectedAMedalCompetition id) (Just medal.competition))
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData =
            \( id, medal ) ->
                Common.defaultCell []
                    (UI.defaultLayoutForTable <| el [ centerY ] <| Common.specialtySelector False (Just sport) (SelectedAMedalSpecialty id) (Just medal.specialty))
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "ANNÉE"
        , viewData =
            \( id, medal ) ->
                Common.centeredCell []
                    (UI.defaultLayoutForTable <| el [ centerY ] <| Common.yearSelector False currentYear (SelectedAMedalYear id) (Just medal.year))
        , sorter = Table.decreasingOrIncreasingBy (\( _, medal ) -> medal.year |> Model.getYear)
        }
    , Table.veryCustomColumn
        { name = ""
        , viewData =
            \( id, _ ) ->
                Common.centeredCell [] (UI.defaultLayoutForTable <| el [ centerY ] <| viewDeleteButton (PressedDeleteMedalButton id))
        , sorter = Table.unsortable
        }
    ]


editYearsInFrenchTeam : Year -> ChampionForm -> Element Msg
editYearsInFrenchTeam currentYear champion =
    Common.viewBlock "Années en équipe de France"
        [ column [ UI.largeSpacing ]
            [ Utils.viewIf (Dict.size champion.yearsInFrenchTeam > 0) <|
                column [ UI.defaultSpacing ]
                    (champion.yearsInFrenchTeam
                        |> Dict.map
                            (\id year ->
                                row [ UI.largeSpacing ]
                                    [ text <| String.fromInt (Model.getYear year)
                                    , viewDeleteButton (PressedDeleteYearInFrenchTeamButton id)
                                    ]
                            )
                        |> Dict.values
                    )
            , viewAddButton "Ajouter une année" PressedAddYearInFrenchTeamButton
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
    UI.textInput [ width fill ]
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
                        [ text "Choisir une photo"
                            |> UI.smallButton (Just BeganProfilePictureSelection)
                            |> Button.withBackgroundColor Color.green
                            |> Button.viewButton
                        ]

            Just { filename, base64 } ->
                column [ UI.defaultSpacing, width fill ]
                    [ let
                        src =
                            base64 |> Maybe.withDefault (Route.baseEndpoint ++ "/uploads/" ++ filename)
                      in
                      image [ width <| px 200 ] { src = src, description = "Photo de profil" }
                    , el [ centerX ]
                        (text "Changer la photo"
                            |> UI.smallButton (Just BeganProfilePictureSelection)
                            |> Button.withBackgroundColor Color.green
                            |> Button.viewButton
                        )
                    ]


editHighlights : ChampionForm -> Element Msg
editHighlights { highlights } =
    column [ UI.largeSpacing, width fill ]
        [ el [ Font.bold ] <| text "Faits marquants"
        , Utils.viewIf (Dict.size highlights > 0) <|
            column [ UI.defaultSpacing, width fill ]
                (highlights
                    |> Dict.map
                        (\id highlight ->
                            row [ UI.defaultSpacing, width fill ]
                                [ UI.textInput [ width fill ]
                                    { onChange = UpdatedHighlight id
                                    , text = highlight
                                    , placeholder = Nothing
                                    , label = Nothing
                                    }
                                , viewDeleteButton (PressedDeleteHighlightButton id)
                                ]
                        )
                    |> Dict.values
                )
        , viewAddButton "Ajouter un fait marquant" PressedAddHighlightButton
        ]


viewButtons : Element Msg
viewButtons =
    row [ UI.defaultSpacing, alignRight ]
        [ text "Annuler"
            |> Button.makeButton (Just RequestedPreviousPage)
            |> Button.withBackgroundColor Color.lightGrey
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


viewAddButton : String -> Msg -> Element Msg
viewAddButton label msg =
    row [ Font.color Color.green, UI.defaultSpacing, mouseOver [ Font.color <| Color.makeDarker Color.green ] ] [ el [ UI.largestFont ] <| UI.viewIcon "plus-circle", text label ]
        |> UI.smallButton (Just msg)
        |> Button.withPadding (padding 0)
        |> Button.viewButton


viewDeleteButton : Msg -> Element Msg
viewDeleteButton msg =
    text "Supprimer"
        |> UI.smallButton (Just msg)
        |> Button.withBackgroundColor Color.red
        |> Button.viewButton
