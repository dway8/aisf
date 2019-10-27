module Page.Champion exposing (init, view, viewPictureDialog)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Dict exposing (Dict)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html
import Html.Attributes as HA
import Model exposing (Attachment, Champion, ChampionPageModel, Medal, Msg(..), Picture, ProExperience, Sport)
import RemoteData exposing (RemoteData(..), WebData)
import Route
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : Bool -> Maybe Id -> Id -> ( ChampionPageModel, Cmd Msg )
init isAdmin championLoggedIn id =
    ( { id = id
      , champion = Loading
      , medalsTableState = Table.initialSort "ANNÉE"
      , pictureDialog = Nothing
      }
    , Api.getChampion (Model.isAdminOrCurrentChampion isAdmin championLoggedIn id) id
    )


view : Bool -> Maybe Id -> ChampionPageModel -> Element Msg
view isAdmin championLoggedIn { id, champion, medalsTableState } =
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
            , Utils.viewIf adminOrCurrentChampion
                (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "edit", text <| "Éditer la fiche" ]
                    |> Button.makeButton (Just <| PressedEditChampionButton id)
                    |> Button.withBackgroundColor Color.orange
                    |> Button.withAttrs []
                    |> Button.viewButton
                )
            ]
        , case champion of
            Success champ ->
                column [ UI.largerSpacing, width fill ]
                    [ row [ UI.largeSpacing ]
                        [ Common.viewProfilePicture 150 champ.profilePicture
                        , column [ UI.largeSpacing, alignBottom ]
                            [ column [ UI.defaultSpacing ]
                                [ el [ Font.bold, UI.largestFont ] <| text champ.firstName
                                , el [ Font.bold, UI.largeFont ] <| text champ.lastName
                                ]
                            , row [ UI.defaultSpacing ]
                                [ image [ width <| px 50 ] { src = Model.resourcesEndpoint ++ "/images/" ++ Model.getIsMemberIcon champ.isMember, description = "" }
                                , image [ width <| px 50 ] { src = Model.resourcesEndpoint ++ "/images/" ++ Model.getSportIcon champ.sport, description = Model.sportToString champ.sport }
                                , text (Model.sportToString champ.sport)
                                ]
                            ]
                        ]
                    , champ.intro
                        |> Maybe.map
                            (\intro ->
                                el
                                    [ width <| maximum 900 fill
                                    , Background.color Color.lighterGrey
                                    , UI.largePadding
                                    ]
                                <|
                                    viewTextArea intro
                            )
                        |> Maybe.withDefault none
                    , viewHighlights champ.highlights
                    , Utils.viewIf adminOrCurrentChampion <| viewPrivateInfo champ
                    , viewSportCareer champ
                    , viewProfessionalCareer champ
                    , viewPictures champ
                    , viewMedals medalsTableState champ
                    ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]


viewTextArea : String -> Element Msg
viewTextArea t =
    html <|
        Html.p
            [ HA.style "white-space" "pre-wrap"
            , HA.style "overflow-wrap" "break-word"
            , HA.style "word-wrap" "break-word"
            , HA.style "margin" "0"
            ]
            [ Html.text t
            ]


viewHighlights : List String -> Element Msg
viewHighlights highlights =
    Utils.viewIf (highlights /= []) <|
        column [ UI.defaultSpacing, paddingEach { top = 0, bottom = 0, right = 0, left = 30 } ]
            (highlights
                |> List.map
                    (\h ->
                        row [ UI.defaultSpacing ]
                            [ el [ Font.color Color.blue, UI.smallestFont, moveDown 2 ] <| UI.viewIcon "circle"
                            , paragraph [ UI.largeFont, Font.bold ] [ text h ]
                            ]
                    )
            )


viewPrivateInfo : Champion -> Element Msg
viewPrivateInfo champion =
    Common.viewBlock "Informations privées"
        [ Common.viewInfoRow "Numéro champion" (champion.login |> Maybe.map String.fromInt |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Date de naissance" (champion.birthDate |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Adresse" (champion.address |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Adresse e-mail" (champion.email |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "N° de téléphone" (champion.phoneNumber |> Maybe.withDefault "-" |> text)
        ]


viewSportCareer : Champion -> Element Msg
viewSportCareer champion =
    Common.viewBlock "Carrière sportive"
        [ Common.viewInfoRow "Participation aux JO" (champion.olympicGamesParticipation |> Maybe.withDefault "-" |> viewTextArea)
        , Common.viewInfoRow "Championnats du monde" (champion.worldCupParticipation |> Maybe.withDefault "-" |> viewTextArea)
        , Common.viewInfoRow "Palmarès" (champion.trackRecord |> Maybe.withDefault "-" |> viewTextArea)
        , Common.viewInfoRow "Ton meilleur souvenir" (champion.bestMemory |> Maybe.withDefault "-" |> viewTextArea)
        , Common.viewInfoRow "Décoration" (champion.decoration |> Maybe.withDefault "-" |> text)
        , column [ UI.defaultSpacing, width fill, paddingEach { top = 10, bottom = 0, left = 0, right = 0 } ]
            [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Années en équipe de France"
            , if champion.yearsInFrenchTeam == [] then
                el [ Font.italic ] <| text "Aucune année renseignée"

              else
                wrappedRow [ width fill, UI.defaultSpacing ]
                    (champion.yearsInFrenchTeam
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


viewProfessionalCareer : Champion -> Element Msg
viewProfessionalCareer champion =
    Common.viewBlock "Carrière professionnelle"
        [ Common.viewInfoRow "Formation" (champion.background |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Bénévolat" (champion.volunteering |> Maybe.withDefault "-" |> viewTextArea)
        , column [ UI.defaultSpacing, width fill, paddingEach { top = 10, bottom = 0, left = 0, right = 0 } ]
            [ el [ Font.bold, UI.largeFont, Font.color Color.blue ] <| text "Expériences professionnelles"
            , if champion.proExperiences == [] then
                el [ Font.italic ] <| text "Aucune expérience renseignée"

              else
                column [ spacing 7, width fill ]
                    (champion.proExperiences
                        |> List.map viewProExperience
                    )
            ]
        ]


viewProExperience : ProExperience -> Element Msg
viewProExperience exp =
    column [ UI.defaultSpacing, width fill, Background.color Color.lightestGrey, UI.largePadding ]
        [ Common.viewInfoRow "Secteurs" (exp.sectors |> String.join ", " |> text)
        , Common.viewInfoRow "Titre" (exp.title |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Entreprise" (exp.companyName |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Description" (exp.description |> Maybe.withDefault "-" |> viewTextArea)
        , Common.viewInfoRow "Site internet" (exp.website |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Contact" (exp.contact |> Maybe.withDefault "-" |> text)
        ]


viewPictures : Champion -> Element Msg
viewPictures champion =
    let
        id =
            Model.getId champion
    in
    Common.viewBlock "Photos"
        [ if champion.pictures == [] then
            el [ Font.italic ] <| text "Aucune photo pour l'instant"

          else
            row [ width fill, clipX, scrollbarX, UI.defaultSpacing ]
                (champion.pictures
                    |> List.indexedMap
                        (\idx { attachment } ->
                            image [ onClick <| ClickedOnPicture idx, width <| px 200 ] { src = Route.baseEndpoint ++ "/uploads/" ++ id ++ "/" ++ attachment.filename, description = "" }
                        )
                )
        ]


viewMedals : Table.State -> Champion -> Element Msg
viewMedals tableState champion =
    Common.viewBlock "Palmarès"
        (champion.medals
            |> Table.view tableConfig tableState
            |> html
            |> el [ htmlAttribute <| HA.id "champion-medals-list", width fill ]
            |> List.singleton
        )


tableConfig : Table.Config Medal Msg
tableConfig =
    let
        tableCustomizations =
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = Model.getId
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = always [ HA.style "cursor" "pointer" ] }
        }


attrsForHeaders : Dict String (List (Html.Attribute msg))
attrsForHeaders =
    Dict.fromList <|
        [ ( "MÉDAILLE", [ HA.style "text-align" "center" ] )
        , ( "ANNÉE", [ HA.style "text-align" "center" ] )
        ]


tableColumns : List (Table.Column Medal Msg)
tableColumns =
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


viewPictureDialog : Id -> Picture -> List Picture -> Element Msg
viewPictureDialog (Id championId) { attachment } pictures =
    let
        displayArrow =
            List.length pictures > 1

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
