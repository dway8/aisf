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
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : Bool -> Id -> ( ChampionPageModel, Cmd Msg )
init isAdmin id =
    ( { id = id
      , champion = Loading
      , medalsTableState = Table.initialSort "ANNÉE"
      , pictureDialog = Nothing
      }
    , Api.getChampion isAdmin id
    )


view : Bool -> Maybe Id -> ChampionPageModel -> Element Msg
view isAdmin championLoggedIn { id, champion, medalsTableState } =
    column [ UI.largeSpacing, width fill ]
        [ row [ UI.largeSpacing ]
            [ Utils.viewIf (championLoggedIn == Nothing)
                (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "arrow-left", text <| "Retour à la liste" ]
                    |> Button.makeButton (Just GoBack)
                    |> Button.withBackgroundColor Color.lightGrey
                    |> Button.withAttrs []
                    |> Button.viewButton
                )
            , Utils.viewIf
                (isAdmin || (championLoggedIn |> Maybe.map ((==) id) |> Maybe.withDefault False))
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
                        , column [ UI.largeSpacing, alignTop ]
                            [ el [ Font.bold, UI.largestFont ] <| text champ.lastName
                            , el [ Font.bold, UI.largestFont ] <| text champ.firstName
                            , row [ UI.defaultSpacing ]
                                [ image [ width <| px 50 ] { src = Model.resourcesEndpoint ++ "/images/" ++ Model.getSportIcon champ.sport, description = Model.sportToString champ.sport }
                                , text (Model.sportToString champ.sport)
                                ]
                            , image [ width <| px 50 ] { src = Model.resourcesEndpoint ++ "/images/" ++ Model.getIsMemberIcon champ.isMember, description = "" }
                            ]
                        ]
                    , champ.intro
                        |> Maybe.map (\intro -> paragraph [ width <| maximum 900 fill, Background.color Color.lighterGrey, UI.largePadding ] [ text intro ])
                        |> Maybe.withDefault none
                    , viewHighlights champ.highlights
                    , Utils.viewIf isAdmin <| viewPrivateInfo champ
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


viewHighlights : List String -> Element Msg
viewHighlights highlights =
    Utils.viewIf (highlights /= []) <|
        column [ UI.defaultSpacing, paddingXY 10 0 ]
            (highlights
                |> List.map (\h -> row [ UI.defaultSpacing ] [ text "-", text h ])
            )


viewPrivateInfo : Champion -> Element Msg
viewPrivateInfo champion =
    Common.viewBlock "Informations privées"
        [ Common.viewInfoRow "Date de naissance" (champion.birthDate |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Adresse" (champion.address |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Adresse e-mail" (champion.email |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "N° de téléphone" (champion.phoneNumber |> Maybe.withDefault "-" |> text)
        ]


viewSportCareer : Champion -> Element Msg
viewSportCareer champion =
    Common.viewBlock "Carrière sportive"
        [ Common.viewInfoRow "Années en équipe de France" (champion.frenchTeamParticipation |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Participation aux JO" (champion.olympicGamesParticipation |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Championnats du monde" (champion.worldCupParticipation |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Palmarès" (champion.trackRecord |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Ton meilleur souvenir" (champion.bestMemory |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Décoration" (champion.decoration |> Maybe.withDefault "-" |> text)
        ]


viewProfessionalCareer : Champion -> Element Msg
viewProfessionalCareer champion =
    Common.viewBlock "Carrière professionnelle"
        [ Common.viewInfoRow "Formation" (champion.background |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Bénévolat" (champion.volunteering |> Maybe.withDefault "-" |> text)
        , column [ UI.defaultSpacing, width fill ]
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
    column [ UI.smallSpacing, width fill, Background.color Color.lightestGrey, UI.largePadding ]
        [ Common.viewInfoRow "Secteurs" (exp.sectors |> String.join ", " |> text)
        , Common.viewInfoRow "Titre" (exp.title |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Entreprise" (exp.companyName |> Maybe.withDefault "-" |> text)
        , Common.viewInfoRow "Description" (exp.description |> Maybe.withDefault "-" |> text)
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
                            image [ onClick <| ClickedOnPicture idx, width <| px 200 ] { src = Model.baseEndpoint ++ "/uploads/" ++ id ++ "/" ++ attachment.filename, description = "" }
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
            image [ centerX, centerY ] { src = Model.baseEndpoint ++ "/uploads/" ++ championId ++ "/" ++ attachment.filename, description = "" }
        , closable = Just ClickedOnPictureDialogBackground
        }
