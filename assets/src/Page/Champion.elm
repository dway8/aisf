module Page.Champion exposing (init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Model exposing (Champion, ChampionPageModel, Msg(..), Sport)
import RemoteData exposing (RemoteData(..), WebData)
import UI
import UI.Button as Button
import UI.Color


init : Id -> ( ChampionPageModel, Cmd Msg )
init id =
    ( { id = id, champion = Loading }, Api.getChampion id )


view : ChampionPageModel -> Element Msg
view { id, champion } =
    column [ spacing 10 ]
        [ link []
            { url = "/champions"
            , label = row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "arrow-left", text <| "Retour à la liste" ]
            }
            |> Button.makeButton Nothing
            |> Button.withBackgroundColor UI.Color.lighterGrey
            |> Button.withAttrs []
            |> Button.viewButton
        , case champion of
            Success champ ->
                column [ spacing 15 ]
                    [ column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "INFOS"
                        , column [ spacing 4 ]
                            [ Common.viewField "N°" (Model.getId champ)
                            , Common.viewField "Nom" champ.lastName
                            , Common.viewField "Prénom" champ.firstName
                            , Common.viewField "Discipline" (Model.sportToString champ.sport)
                            ]
                        , Common.viewTextArea "Intro" champ.intro
                        ]
                    , column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "EXPÉRIENCES PROFESSIONNELLES"
                        , column [ spacing 7 ]
                            (champ.proExperiences
                                |> List.map Common.viewProExperience
                            )
                        ]
                    , column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "PALMARÈS"
                        , column [ spacing 7 ]
                            (champ.medals
                                |> List.map Common.viewMedal
                            )
                        ]
                    , column [ spacing 10 ]
                        [ el [ Font.bold, Font.size 18 ] <| text "ANNÉES EN ÉQUIPE DE FRANCE"
                        , column [ spacing 7 ]
                            (if champ.yearsInFrenchTeam == [] then
                                [ text "Aucune" ]

                             else
                                champ.yearsInFrenchTeam
                                    |> List.map Model.getYear
                                    |> List.sort
                                    |> List.map
                                        (\year ->
                                            text <| String.fromInt year
                                        )
                            )
                        ]
                    ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]
