module Page.NewChampion exposing (init, view)

import Api
import Editable exposing (Editable(..))
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Html.Attributes as HA
import Model exposing (..)
import Page.Champion as Champion
import RemoteData as RD exposing (RemoteData(..), WebData)
import UI
import UI.Button as Button
import UI.Color as Color


init : ( NewChampionPageModel, Cmd Msg )
init =
    ( { champion = Champion.initChampion
      , saveRequest = NotAsked
      }
    , Cmd.none
    )


view : NewChampionPageModel -> Element Msg
view { champion, saveRequest } =
    column [ UI.largeSpacing, width <| px 600 ]
        [ row [ UI.defaultSpacing ]
            [ row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "arrow-left", text <| "Retour à la liste" ]
                |> Button.makeButton (Just RequestedPreviousListingPage)
                |> Button.withBackgroundColor Color.lightGrey
                |> Button.withAttrs []
                |> Button.viewButton
            ]
        , case champion.presentation of
            ReadOnly _ ->
                -- should not happen
                none

            Editable _ presentation ->
                column [ UI.largerSpacing ]
                    [ el [ UI.largestFont, Font.bold ] <| text "Nouveau coureur"
                    , column [ UI.defaultSpacing ] <| Champion.editPresentation False champion presentation
                    ]
        , el [ alignRight ] <|
            case saveRequest of
                NotAsked ->
                    text "Enregistrer et passer à l'étape suivante"
                        |> Button.makeButton (Just PressedSaveNewChampionButton)
                        |> Button.withBackgroundColor Color.green
                        |> Button.withAttrs [ htmlAttribute <| HA.id "save-champion-btn" ]
                        |> Button.viewButton

                _ ->
                    row [ UI.defaultSpacing ] [ UI.spinner, text "Sauvegarde en cours..." ]
                        |> Button.makeButton Nothing
                        |> Button.withBackgroundColor Color.green
                        |> Button.withDisabled True
                        |> Button.withAlpha 0.5
                        |> Button.withCursor UI.notAllowedCursor
                        |> Button.withAttrs [ htmlAttribute <| HA.id "save-champion-btn" ]
                        |> Button.viewButton
        ]
