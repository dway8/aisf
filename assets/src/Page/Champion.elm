module Page.Champion exposing (editPresentation, init, initChampion, toChampionLite, view, viewPictureDialog)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Dict exposing (Dict)
import Dropdown
import Editable exposing (Editable(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input
import Graphql.Http
import Html
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (..)
import RemoteData as RD exposing (RemoteData(..), WebData)
import Route
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : Year -> Bool -> Maybe Id -> Id -> ( ChampionPageModel, Cmd Msg )
init currentYear isAdmin championLoggedIn id =
    case id of
        Id "new" ->
            ( { id = id
              , champion = Success initChampion
              , medalsTableState = Table.initialSort "ANNÉE"
              , pictureDialog = Nothing
              , sectorDropdown = Dropdown.init
              , currentYear = currentYear
              }
            , Cmd.none
            )

        _ ->
            ( { id = id
              , champion = Loading
              , medalsTableState = Table.initialSort "ANNÉE"
              , pictureDialog = Nothing
              , sectorDropdown = Dropdown.init
              , currentYear = currentYear
              }
            , Api.getChampion (Model.isAdminOrCurrentChampion isAdmin championLoggedIn id) id
            )


initChampion : Champion
initChampion =
    { id = Id "new"
    , presentation =
        Editable
            { lastName = ""
            , firstName = ""
            , sport = SkiAlpin
            , isMember = False
            , intro = Nothing
            , highlights = Dict.empty
            , profilePicture = Nothing
            }
            { lastName = ""
            , firstName = ""
            , sport = SkiAlpin
            , isMember = False
            , intro = Nothing
            , highlights = Dict.empty
            , profilePicture = Nothing
            }
    , privateInfo =
        ReadOnly
            { login = Nothing
            , birthDate = Nothing
            , address = Nothing
            , email = Nothing
            , phoneNumber = Nothing
            }
    , sportCareer =
        ReadOnly
            { olympicGamesParticipation = Nothing
            , worldCupParticipation = Nothing
            , trackRecord = Nothing
            , bestMemory = Nothing
            , decoration = Nothing
            , yearsInFrenchTeam = Dict.empty
            }
    , professionalCareer =
        ReadOnly
            { background = Nothing
            , volunteering = Nothing
            , proExperiences = Dict.empty
            }
    , pictures = ReadOnly Dict.empty
    , medals = ReadOnly Dict.empty
    }


view : RemoteData (Graphql.Http.Error Sectors) Sectors -> Bool -> Maybe Id -> ChampionPageModel -> Element Msg
view rdSectors isAdmin championLoggedIn { id, champion, medalsTableState, currentYear, sectorDropdown } =
    let
        adminOrCurrentChampion =
            Model.isAdminOrCurrentChampion isAdmin championLoggedIn id
    in
    column [ UI.largeSpacing, width fill ]
        [ row [ UI.defaultSpacing ]
            [ Utils.viewIf (championLoggedIn == Nothing)
                (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "arrow-left", text <| "Retour à la liste" ]
                    |> Button.makeButton (Just RequestedPreviousListingPage)
                    |> Button.withBackgroundColor Color.lightGrey
                    |> Button.withAttrs []
                    |> Button.viewButton
                )
            ]
        , case champion of
            Success champ ->
                column [ UI.largerSpacing, width fill ]
                    [ viewPresentation adminOrCurrentChampion champ
                    , Utils.viewIf adminOrCurrentChampion <| viewPrivateInfo adminOrCurrentChampion champ
                    , viewSportCareer currentYear adminOrCurrentChampion champ
                    , viewProfessionalCareer (rdSectors |> RD.withDefault []) sectorDropdown adminOrCurrentChampion champ
                    , viewPictures adminOrCurrentChampion champ
                    , viewMedals (champ.presentation |> Editable.value |> .sport) currentYear adminOrCurrentChampion medalsTableState champ
                    ]

            NotAsked ->
                none

            Loading ->
                UI.spinner

            _ ->
                text "Une erreur s'est produite."
        ]


viewPresentation : Bool -> Champion -> Element Msg
viewPresentation isEditable champion =
    case champion.presentation of
        ReadOnly presentation ->
            Common.viewBlock isEditable
                PresentationBlock
                "Présentation"
                [ row [ UI.largeSpacing ]
                    [ Common.viewProfilePicture 150 presentation.profilePicture
                    , column [ UI.largeSpacing, alignBottom ]
                        [ column [ UI.defaultSpacing ]
                            [ el [ Font.bold, UI.largestFont ] <| text presentation.firstName
                            , el [ UI.largeFont ] <| text <| String.toUpper presentation.lastName
                            ]
                        , row [ UI.defaultSpacing ]
                            [ image [ width <| px 50 ] { src = Model.resourcesEndpoint ++ "/images/" ++ Model.getIsMemberIcon presentation.isMember, description = "" }
                            , image [ width <| px 50 ] { src = Model.resourcesEndpoint ++ "/images/" ++ Model.getSportIcon presentation.sport, description = Model.sportToString presentation.sport }
                            , text (Model.sportToString presentation.sport)
                            ]
                        ]
                    ]
                , presentation.intro
                    |> Maybe.map
                        (\intro ->
                            el
                                [ width <| maximum 900 fill
                                , Background.color Color.lighterGrey
                                , UI.largePadding
                                ]
                            <|
                                UI.viewTextArea intro
                        )
                    |> Maybe.withDefault none
                , Utils.viewIf (presentation.highlights /= Dict.empty) <|
                    column [ UI.defaultSpacing, paddingEach { top = 0, bottom = 0, right = 0, left = 30 } ]
                        (presentation.highlights
                            |> Dict.values
                            |> List.map
                                (\h ->
                                    row [ UI.defaultSpacing ]
                                        [ el [ Font.color Color.blue, UI.smallestFont, moveDown 2 ] <| UI.viewIcon "circle"
                                        , paragraph [ UI.largeFont, Font.bold ] [ text h ]
                                        ]
                                )
                        )
                ]

        Editable _ newPresentation ->
            Common.viewBlock False
                PresentationBlock
                "Présentation"
                (editPresentation True champion newPresentation ++ [ viewButtons PresentationBlock ])


editPresentation : Bool -> Champion -> Presentation -> List (Element Msg)
editPresentation fullEdition champion presentation =
    [ row [ UI.largeSpacing, width <| px 600 ]
        [ Utils.viewIf fullEdition <| editProfilePicture presentation.profilePicture
        , column [ UI.defaultSpacing, width fill ]
            [ viewChampionTextInput FirstName champion
            , viewChampionTextInput LastName champion
            ]
        ]
    , row [ UI.largerSpacing ]
        [ row [ UI.defaultSpacing ] [ el [ Font.bold ] <| text "Discipline", Common.sportSelector False (Just presentation.sport) ]
        , memberCheckbox presentation.isMember
        ]
    , Utils.viewIf fullEdition <| viewChampionTextArea Intro champion
    , Utils.viewIf fullEdition <| editHighlights presentation.highlights
    ]


editProfilePicture : Maybe Attachment -> Element Msg
editProfilePicture profilePicture =
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


editHighlights : Dict Int String -> Element Msg
editHighlights highlights =
    column [ UI.defaultSpacing, width fill ]
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


viewPrivateInfo : Bool -> Champion -> Element Msg
viewPrivateInfo isEditable champion =
    case champion.privateInfo of
        ReadOnly privateInfo ->
            Common.viewBlock isEditable
                PrivateInfoBlock
                "Informations privées"
                [ Common.viewInfoRow "Numéro champion" (privateInfo.login |> Maybe.map String.fromInt |> Maybe.withDefault "-" |> text)
                , Common.viewInfoRow "Date de naissance" (privateInfo.birthDate |> Maybe.withDefault "-" |> text)
                , Common.viewInfoRow "Adresse" (privateInfo.address |> Maybe.withDefault "-" |> text)
                , Common.viewInfoRow "Adresse e-mail" (privateInfo.email |> Maybe.withDefault "-" |> text)
                , Common.viewInfoRow "N° de téléphone" (privateInfo.phoneNumber |> Maybe.withDefault "-" |> text)
                ]

        Editable _ newPrivateInfo ->
            Common.viewBlock False
                PrivateInfoBlock
                "Informations privées"
                [ row [ UI.defaultSpacing, width fill ]
                    [ UI.textInput ([ width fill ] ++ UI.disabledTextInputAttrs)
                        { onChange = always NoOp
                        , text = newPrivateInfo.login |> Maybe.map String.fromInt |> Maybe.withDefault ""
                        , placeholder = Nothing
                        , label = Just "Numéro champion"
                        }
                    , viewChampionTextInput BirthDate champion
                    ]
                , viewChampionTextInput Address champion
                , row [ UI.defaultSpacing, width fill ]
                    [ viewChampionTextInput Email champion
                    , viewChampionTextInput PhoneNumber champion
                    ]
                , viewButtons PrivateInfoBlock
                ]


viewSportCareer : Year -> Bool -> Champion -> Element Msg
viewSportCareer currentYear isEditable champion =
    case champion.sportCareer of
        ReadOnly sportCareer ->
            Common.viewBlock isEditable
                SportCareerBlock
                "Carrière sportive"
                [ Common.viewInfoRow "Participation aux JO" (sportCareer.olympicGamesParticipation |> Maybe.withDefault "-" |> UI.viewTextArea)
                , Common.viewInfoRow "Championnats du monde" (sportCareer.worldCupParticipation |> Maybe.withDefault "-" |> UI.viewTextArea)
                , Common.viewInfoRow "Palmarès" (sportCareer.trackRecord |> Maybe.withDefault "-" |> UI.viewTextArea)
                , Common.viewInfoRow "Ton meilleur souvenir" (sportCareer.bestMemory |> Maybe.withDefault "-" |> UI.viewTextArea)
                , Common.viewInfoRow "Décoration" (sportCareer.decoration |> Maybe.withDefault "-" |> text)
                , column [ UI.defaultSpacing, width fill, paddingEach { top = 10, bottom = 0, left = 0, right = 0 } ]
                    [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Années en équipe de France"
                    , if sportCareer.yearsInFrenchTeam == Dict.empty then
                        el [ Font.italic ] <| text "Aucune année renseignée"

                      else
                        wrappedRow [ width fill, UI.defaultSpacing ]
                            (sportCareer.yearsInFrenchTeam
                                |> Dict.values
                                |> List.map
                                    (\year ->
                                        year
                                            |> Model.getYear
                                            |> String.fromInt
                                            |> text
                                            |> el UI.badgeAttrs
                                    )
                            )
                    ]
                ]

        Editable _ newSportCareer ->
            Common.viewBlock False
                SportCareerBlock
                "Carrière sportive"
                [ viewChampionTextArea OlympicGamesParticipation champion
                , viewChampionTextArea WorldCupParticipation champion
                , viewChampionTextArea TrackRecord champion
                , viewChampionTextArea BestMemory champion
                , viewChampionTextInput Decoration champion
                , column [ UI.defaultSpacing, width fill, paddingEach { top = 10, bottom = 0, right = 0, left = 0 } ]
                    [ row [ UI.defaultSpacing ]
                        [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Années en équipe de France"
                        ]
                    , Utils.viewIf (Dict.size newSportCareer.yearsInFrenchTeam > 0) <|
                        column [ UI.defaultSpacing ]
                            (newSportCareer.yearsInFrenchTeam
                                |> Dict.map
                                    (\id year ->
                                        row [ UI.largeSpacing ]
                                            [ Common.yearSelector False currentYear (SelectedAYearInFrenchTeam id) (Just year)
                                            , viewDeleteButton (PressedDeleteYearInFrenchTeamButton id)
                                            ]
                                    )
                                |> Dict.values
                            )
                    , viewAddButton "Ajouter une année" PressedAddYearInFrenchTeamButton
                    ]
                , viewButtons SportCareerBlock
                ]


viewProfessionalCareer : Sectors -> Dropdown.Model -> Bool -> Champion -> Element Msg
viewProfessionalCareer sectors sectorDropdown isEditable champion =
    case champion.professionalCareer of
        ReadOnly pc ->
            Common.viewBlock isEditable
                ProfessionalCareerBlock
                "Carrière professionnelle"
                [ Common.viewInfoRow "Formation" (pc.background |> Maybe.withDefault "-" |> text)
                , Common.viewInfoRow "Bénévolat" (pc.volunteering |> Maybe.withDefault "-" |> UI.viewTextArea)
                , column [ UI.defaultSpacing, width fill, paddingEach { top = 10, bottom = 0, left = 0, right = 0 } ]
                    [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Expériences professionnelles"
                    , if pc.proExperiences == Dict.empty then
                        el [ Font.italic ] <| text "Aucune expérience renseignée"

                      else
                        column [ spacing 7, width fill ]
                            (pc.proExperiences
                                |> Dict.values
                                |> List.map viewProExperience
                            )
                    ]
                ]

        Editable _ newProfessionalCareer ->
            Common.viewBlock False
                ProfessionalCareerBlock
                "Carrière professionnelle"
                [ viewChampionTextInput Background champion
                , viewChampionTextArea Volunteering champion
                , column [ UI.defaultSpacing, width fill, paddingEach { top = 10, bottom = 0, right = 0, left = 0 } ]
                    [ row [ UI.defaultSpacing ]
                        [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Expériences professionnelles"
                        ]
                    , editProExperiences sectors sectorDropdown newProfessionalCareer.proExperiences
                    , viewAddButton "Ajouter une expérience" PressedAddProExperienceButton
                    ]
                , viewButtons ProfessionalCareerBlock
                ]


editProExperiences : Sectors -> Dropdown.Model -> Dict Int ProExperience -> Element Msg
editProExperiences sectors sectorDropdown proExperiences =
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
                        , let
                            ( label, value ) =
                                getProExperienceFormFieldData Description exp
                          in
                          viewGenericTextArea label value (UpdatedProExperienceField id Description)
                        , row [ UI.defaultSpacing, width fill ]
                            [ viewProExperienceTextInput id Website exp
                            , viewProExperienceTextInput id Contact exp
                            ]
                        , el [ alignRight ] <| viewDeleteButton (PressedDeleteProExperienceButton id)
                        ]
                )
            |> Dict.values
        )


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


viewProExperience : ProExperience -> Element Msg
viewProExperience exp =
    column [ UI.defaultSpacing, width fill, Background.color Color.lightestGrey, UI.largePadding ]
        [ Common.viewInfoRow "Secteurs" (exp.sectors |> String.join ", " |> text)
        , Common.viewInfoRow "Titre" (exp.title |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Entreprise" (exp.companyName |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Description" (exp.description |> Maybe.withDefault "-" |> UI.viewTextArea)
        , Common.viewInfoRow "Site internet" (exp.website |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Contact" (exp.contact |> Maybe.withDefault "-" |> text)
        ]


viewPictures : Bool -> Champion -> Element Msg
viewPictures isEditable champion =
    let
        id =
            Model.getId champion
    in
    case champion.pictures of
        ReadOnly pictures ->
            Common.viewBlock isEditable
                PicturesBlock
                "Photos"
                [ if pictures == Dict.empty then
                    el [ Font.italic ] <| text "Aucune photo pour l'instant"

                  else
                    row [ width fill, clipX, scrollbarX, UI.defaultSpacing ]
                        (pictures
                            |> Dict.map
                                (\idx { attachment } ->
                                    image [ onClick <| ClickedOnPicture idx, width <| px 200 ] { src = Route.baseEndpoint ++ "/uploads/" ++ id ++ "/" ++ attachment.filename, description = "" }
                                )
                            |> Dict.values
                        )
                ]

        Editable _ newPictures ->
            Common.viewBlock False
                PicturesBlock
                "Photos"
                [ Utils.viewIf (newPictures /= Dict.empty) <|
                    row [ width fill, clipX, scrollbarX, UI.defaultSpacing ]
                        (newPictures
                            |> Dict.map (editPicture id)
                            |> Dict.values
                        )
                , viewAddButton "Ajouter une photo" PressedAddPictureButton
                , viewButtons PicturesBlock
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


viewMedals : Sport -> Year -> Bool -> Table.State -> Champion -> Element Msg
viewMedals sport currentYear isEditable tableState champion =
    case champion.medals of
        ReadOnly medals ->
            Common.viewBlock isEditable
                MedalsBlock
                "Palmarès"
                (medals
                    |> Dict.values
                    |> Table.view readonlyTableConfig tableState
                    |> html
                    |> el [ htmlAttribute <| HA.id "champion-medals-list", width fill ]
                    |> List.singleton
                )

        Editable _ newMedals ->
            Common.viewBlock False
                MedalsBlock
                "Palmarès"
                [ column [ width fill ]
                    [ newMedals
                        |> Dict.toList
                        |> Table.view (editableTableConfig sport currentYear) tableState
                        |> html
                        |> el [ htmlAttribute <| HA.id "edit-champion-medals-list", width fill ]
                    , viewAddButton "Ajouter une médaille" PressedAddMedalButton
                    ]
                , viewButtons MedalsBlock
                ]


readonlyTableConfig : Table.Config Medal Msg
readonlyTableConfig =
    let
        tableCustomizations =
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = Model.getId
        , toMsg = TableMsg
        , columns = readonlyTableColumns
        , customizations = { tableCustomizations | rowAttrs = always [ HA.style "cursor" "pointer" ] }
        }


editableTableConfig : Sport -> Year -> Table.Config ( Int, Medal ) Msg
editableTableConfig sport currentYear =
    let
        tableCustomizations =
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = Tuple.second >> Model.getId
        , toMsg = TableMsg
        , columns = editableTableColumns sport currentYear
        , customizations = { tableCustomizations | rowAttrs = always [] }
        }


attrsForHeaders : Dict String (List (Html.Attribute msg))
attrsForHeaders =
    Dict.fromList <|
        [ ( "MÉDAILLE", [ HA.style "text-align" "center" ] )
        , ( "ANNÉE", [ HA.style "text-align" "center" ] )
        ]


readonlyTableColumns : List (Table.Column Medal Msg)
readonlyTableColumns =
    [ Table.veryCustomColumn
        { name = "MÉDAILLE"
        , viewData = \medal -> Common.centeredCell [] (Common.medalIconHtml medal)
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "TYPE"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| Model.medalTypeToDisplay medal.medalType)
        , sorter = Table.decreasingOrIncreasingBy (.medalType >> Model.medalTypeToDisplay)
        }
    , Common.competitionColumn
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| Model.specialtyToDisplay medal.specialty)
        , sorter = Table.decreasingOrIncreasingBy (.specialty >> Model.specialtyToDisplay)
        }
    , Common.yearColumn
    ]


editableTableColumns : Sport -> Year -> List (Table.Column ( Int, Medal ) Msg)
editableTableColumns sport currentYear =
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


viewChampionTextInput : FormField -> Champion -> Element Msg
viewChampionTextInput field champion =
    let
        ( label, value, block ) =
            getChampionFieldData field champion
    in
    UI.textInput [ width fill ]
        { onChange = UpdatedChampionField block field
        , text = value
        , placeholder = Nothing
        , label = Just label
        }


viewChampionTextArea : FormField -> Champion -> Element Msg
viewChampionTextArea field champion =
    let
        ( label, value, block ) =
            getChampionFieldData field champion
    in
    viewGenericTextArea label value (UpdatedChampionField block field)


viewGenericTextArea : String -> String -> (String -> Msg) -> Element Msg
viewGenericTextArea label value msg =
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


getChampionFieldData : FormField -> Champion -> ( String, String, FormBlock )
getChampionFieldData field form =
    case field of
        FirstName ->
            ( "Prénom", form.presentation |> Editable.value |> .firstName, PresentationBlock )

        LastName ->
            ( "Nom", form.presentation |> Editable.value |> .lastName, PresentationBlock )

        Intro ->
            ( "Intro", form.presentation |> Editable.value |> .intro |> Maybe.withDefault "", PresentationBlock )

        OlympicGamesParticipation ->
            ( "Participation aux JO", form.sportCareer |> Editable.value |> .olympicGamesParticipation |> Maybe.withDefault "", SportCareerBlock )

        WorldCupParticipation ->
            ( "Championnats du monde", form.sportCareer |> Editable.value |> .worldCupParticipation |> Maybe.withDefault "", SportCareerBlock )

        TrackRecord ->
            ( "Palmarès", form.sportCareer |> Editable.value |> .trackRecord |> Maybe.withDefault "", SportCareerBlock )

        BestMemory ->
            ( "Ton meilleur souvenir", form.sportCareer |> Editable.value |> .bestMemory |> Maybe.withDefault "", SportCareerBlock )

        Decoration ->
            ( "Décoration", form.sportCareer |> Editable.value |> .decoration |> Maybe.withDefault "", SportCareerBlock )

        Background ->
            ( "Formation", form.professionalCareer |> Editable.value |> .background |> Maybe.withDefault "", ProfessionalCareerBlock )

        Volunteering ->
            ( "Bénévolat", form.professionalCareer |> Editable.value |> .volunteering |> Maybe.withDefault "", ProfessionalCareerBlock )

        BirthDate ->
            ( "Date de naissance", form.privateInfo |> Editable.value |> .birthDate |> Maybe.withDefault "", PrivateInfoBlock )

        Address ->
            ( "Adresse", form.privateInfo |> Editable.value |> .address |> Maybe.withDefault "", PrivateInfoBlock )

        Email ->
            ( "Adresse e-mail", form.privateInfo |> Editable.value |> .email |> Maybe.withDefault "", PrivateInfoBlock )

        PhoneNumber ->
            ( "N° de téléphone", form.privateInfo |> Editable.value |> .phoneNumber |> Maybe.withDefault "", PrivateInfoBlock )

        _ ->
            -- pro experience fields
            ( "", "", PresentationBlock )


viewButtons : FormBlock -> Element Msg
viewButtons block =
    row [ UI.defaultSpacing, alignRight ]
        [ text "Annuler"
            |> Button.makeButton (Just <| PressedCancelEditionButton block)
            |> Button.withBackgroundColor Color.lightGrey
            |> Button.viewButton
        , text "Enregistrer les modifications"
            |> Button.makeButton (Just <| PressedSaveChampionButton block)
            |> Button.withBackgroundColor Color.green
            |> Button.withAttrs [ htmlAttribute <| HA.id "save-champion-btn" ]
            |> Button.viewButton
        ]


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


viewPictureDialog : Id -> Picture -> Editable (Dict Int Picture) -> Element Msg
viewPictureDialog (Id championId) { attachment } pictures =
    let
        displayArrow =
            pictures
                |> Editable.value
                |> (\p -> Dict.size p > 1)

        btn move icon position =
            el
                [ Font.size 30
                , pointer
                , centerY
                , Font.color Color.white
                , position
                , onClick <| RequestedNextPicture move
                ]
            <|
                html <|
                    Html.i [ HA.class ("zmdi zmdi-" ++ icon) ] []
    in
    UI.viewDialog
        { header = Nothing
        , outerSideElements =
            if displayArrow then
                Just ( btn -1 "arrow-left" <| moveLeft 20, btn 1 "arrow-right" <| moveRight 20 )

            else
                Nothing
        , body =
            image [ centerX, centerY ] { src = Route.baseEndpoint ++ "/uploads/" ++ championId ++ "/" ++ attachment.filename, description = "" }
        , closable = Just ClickedOnPictureDialogBackground
        }


toChampionLite : Champion -> ChampionLite
toChampionLite champion =
    let
        presentation =
            champion.presentation |> Editable.value
    in
    { id = champion.id
    , lastName = presentation.lastName
    , firstName = presentation.firstName
    , sport = presentation.sport
    , isMember = presentation.isMember
    , profilePicture = presentation.profilePicture
    , yearsInFrenchTeam = champion.sportCareer |> Editable.value |> .yearsInFrenchTeam |> Dict.values
    , medals = champion.medals |> Editable.value |> Dict.values
    , sectors = champion.professionalCareer |> Editable.value |> .proExperiences |> Dict.values |> List.concatMap .sectors
    }
