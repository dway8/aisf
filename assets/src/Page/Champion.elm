module Page.Champion exposing (init, view)

import Aisf.Scalar exposing (Id(..))
import Api
import Common
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Model exposing (Attachment, Champion, ChampionPageModel, Msg(..), Sport)
import RemoteData exposing (RemoteData(..), WebData)
import UI
import UI.Button as Button
import UI.Color
import Utils


init : Id -> ( ChampionPageModel, Cmd Msg )
init id =
    ( { id = id, champion = Loading }, Api.getChampion id )


view : Bool -> ChampionPageModel -> Element Msg
view isAdmin { id, champion } =
    column [ spacing 10, width fill ]
        [ row [ UI.largeSpacing ]
            [ row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "arrow-left", text <| "Retour à la liste" ]
                |> Button.makeButton (Just GoBack)
                |> Button.withBackgroundColor UI.Color.lighterGrey
                |> Button.withAttrs []
                |> Button.viewButton
            , Utils.viewIf
                isAdmin
                (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "edit", text <| "Éditer la fiche" ]
                    |> Button.makeButton (Just <| PressedEditChampionButton id)
                    |> Button.withBackgroundColor UI.Color.orange
                    |> Button.withAttrs []
                    |> Button.viewButton
                )
            ]
        , case champion of
            Success champ ->
                column [ UI.largeSpacing ]
                    [ row [ UI.largeSpacing ]
                        [ Common.viewProfilePicture 200 champ.profilePicture
                        , column [ UI.defaultSpacing ]
                            [ el [ Font.bold, Font.size 18 ] <| text "INFOS"
                            , column [ spacing 4 ]
                                [ UI.viewField "N°" (Model.getId champ)
                                , UI.viewField "Nom" champ.lastName
                                , UI.viewField "Prénom" champ.firstName
                                , UI.viewField "Discipline" (Model.sportToString champ.sport)
                                ]
                            ]
                        ]
                    , Common.viewTextArea "Intro" (champ.intro |> Maybe.withDefault "")
                    , viewHighlights champ.highlights
                    , column [ UI.defaultSpacing ]
                        [ el [ Font.bold, Font.size 18 ] <| text "EXPÉRIENCES PROFESSIONNELLES"
                        , column [ spacing 7 ]
                            (champ.proExperiences
                                |> List.map Common.viewProExperience
                            )
                        ]
                    , column [ UI.defaultSpacing ]
                        [ el [ Font.bold, Font.size 18 ] <| text "PALMARÈS"
                        , column [ spacing 7 ]
                            (champ.medals
                                |> List.map Common.viewMedal
                            )
                        ]
                    , column [ UI.defaultSpacing ]
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


viewHighlights : List String -> Element Msg
viewHighlights highlights =
    column [ UI.largeSpacing ]
        [ el [ Font.bold ] <| text "Faits marquants"
        , column [ UI.defaultSpacing ]
            (highlights
                |> List.map (\h -> text h)
            )
        ]
