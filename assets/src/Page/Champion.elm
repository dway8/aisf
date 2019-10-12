module Page.Champion exposing (init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html
import Html.Attributes as HA
import Model exposing (Attachment, Champion, ChampionPageModel, Medal, Msg(..), Sport)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : Id -> ( ChampionPageModel, Cmd Msg )
init id =
    ( { id = id, champion = Loading, medalsTableState = Table.initialSort "ANNÉE" }, Api.getChampion id )


view : Bool -> ChampionPageModel -> Element Msg
view isAdmin { id, champion, medalsTableState } =
    column [ UI.largeSpacing, width fill ]
        [ row [ UI.largeSpacing ]
            [ row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "arrow-left", text <| "Retour à la liste" ]
                |> Button.makeButton (Just GoBack)
                |> Button.withBackgroundColor Color.lighterGrey
                |> Button.withAttrs []
                |> Button.viewButton
            , Utils.viewIf
                isAdmin
                (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "edit", text <| "Éditer la fiche" ]
                    |> Button.makeButton (Just <| PressedEditChampionButton id)
                    |> Button.withBackgroundColor Color.orange
                    |> Button.withAttrs []
                    |> Button.viewButton
                )
            ]
        , case champion of
            Success champ ->
                column [ UI.largeSpacing, width fill ]
                    [ row [ UI.largeSpacing ]
                        [ Common.viewProfilePicture 150 champ.profilePicture
                        , column [ UI.largeSpacing, alignTop ]
                            [ el [ Font.bold, UI.largestFont ] <| text champ.lastName
                            , el [ Font.bold, UI.largestFont ] <| text champ.firstName
                            , row [ UI.defaultSpacing ]
                                [ image [ width <| px 50 ] { src = "/images/" ++ Model.getSportIcon champ.sport, description = Model.sportToString champ.sport }
                                , text (Model.sportToString champ.sport)
                                ]
                            , image [ width <| px 50 ] { src = "/images/" ++ Model.getIsMemberIcon champ.isMember, description = "" }
                            ]
                        ]
                    , paragraph [ width <| maximum 900 fill, Background.color Color.lighterGrey, UI.largePadding ] [ text (champ.intro |> Maybe.withDefault "") ]
                    , viewHighlights champ.highlights
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
    column [ UI.defaultSpacing, paddingXY 10 0 ]
        (highlights
            |> List.map (\h -> row [ UI.defaultSpacing ] [ text "-", text h ])
        )


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
            [ el [ Font.bold, UI.largeFont ] <| text "Expériences professionnelles"
            , column [ spacing 7, width fill ]
                (champion.proExperiences
                    |> List.map Common.viewProExperience
                )
            ]
        ]


viewPictures : Champion -> Element Msg
viewPictures champion =
    let
        id =
            Model.getId champion
    in
    Common.viewBlock "Photos"
        [ row [ width fill ]
            (champion.pictures
                |> List.map
                    (\{ attachment } ->
                        el [ width <| px 200 ] <|
                            image [ width <| px 200 ] { src = "/uploads/" ++ id ++ "/" ++ attachment.filename, description = "Photo de profil" }
                    )
            )
        ]


viewMedals : Table.State -> Champion -> Element Msg
viewMedals tableState champion =
    Common.viewBlock "Palmarès"
        (champion.medals
            |> Table.view tableConfig tableState
            |> html
            |> el [ htmlAttribute <| HA.id "champion-medals-list", width <| maximum 680 fill ]
            |> List.singleton
        )


tableConfig : Table.Config Medal Msg
tableConfig =
    let
        tableCustomizations =
            Common.tableCustomizations
    in
    Table.customConfig
        { toId = Model.getId
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = always [ HA.style "cursor" "pointer" ] }
        }


tableColumns : List (Table.Column Medal Msg)
tableColumns =
    [ Table.veryCustomColumn
        { name = "MÉDAILLE"
        , viewData =
            \medal ->
                Common.centeredCell []
                    (Html.img
                        [ HA.style "max-width" "25px"
                        , HA.style "max-height" "25px"
                        , HA.style "object-fit" "contain"
                        , HA.src <| "/images/" ++ Model.getMedalIcon medal.competition medal.medalType
                        , HA.title <| Model.medalTypeToDisplay medal.medalType
                        ]
                        []
                    )
        , sorter = Table.unsortable
        }
    , Table.veryCustomColumn
        { name = "TYPE"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| Model.medalTypeToDisplay medal.medalType)
        , sorter = Table.decreasingOrIncreasingBy (.medalType >> Model.medalTypeToDisplay)
        }
    , Table.veryCustomColumn
        { name = "COMPÉTITION"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| Model.competitionToDisplay medal.competition)
        , sorter = Table.decreasingOrIncreasingBy (.competition >> Model.competitionToDisplay)
        }
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData = \medal -> Common.defaultCell [] (Html.text <| Model.specialtyToDisplay medal.specialty)
        , sorter = Table.decreasingOrIncreasingBy (.specialty >> Model.specialtyToDisplay)
        }
    , Table.veryCustomColumn
        { name = "ANNÉE"
        , viewData = \medal -> Common.centeredCell [] (Html.text <| String.fromInt <| Model.getYear medal.year)
        , sorter = Table.decreasingOrIncreasingBy (.year >> Model.getYear)
        }
    ]
