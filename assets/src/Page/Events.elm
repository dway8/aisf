module Page.Events exposing (init, view)

import Api
import Common
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html
import Html.Attributes as HA
import Model exposing (Competition(..), Event, EventsPageModel, Msg(..), Year)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : Year -> ( EventsPageModel, Cmd Msg )
init currentYear =
    ( { events = Loading
      , tableState = Table.initialSort "ANNÉE"
      , newEvent = Nothing
      , currentYear = currentYear
      }
    , Api.getEvents
    )


view : Bool -> EventsPageModel -> Element Msg
view isAdmin model =
    column [ UI.largeSpacing, width fill ]
        [ Utils.viewIf isAdmin <|
            (row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "plus", text "Ajouter un lieu" ]
                |> Button.makeButton (Just PressedAddEventButton)
                |> Button.withBackgroundColor Color.green
                |> Button.viewButton
            )
        , Utils.viewIf isAdmin
            (model.newEvent
                |> Maybe.map (editNewEvent model.currentYear)
                |> Maybe.withDefault none
            )
        , case model.events of
            Success events ->
                events
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el [ width fill ]

            NotAsked ->
                none

            Loading ->
                UI.spinner

            _ ->
                text "Une erreur s'est produite."
        ]


tableConfig : Table.Config Event Msg
tableConfig =
    let
        tableCustomizations =
            Common.tableCustomizations
    in
    Table.customConfig
        { toId = .place
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = always [] }
        }


tableColumns : List (Table.Column Event Msg)
tableColumns =
    [ Common.yearColumn
    , Common.competitionColumn
    , Table.veryCustomColumn
        { name = "LIEU"
        , viewData = \event -> Common.defaultCell [ HA.style "font-weight" "bold" ] (Html.text event.place)
        , sorter = Table.decreasingOrIncreasingBy .place
        }
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData =
            \event ->
                Common.centeredCell []
                    (event.sport
                        |> Maybe.map Common.sportIconHtml
                        |> Maybe.withDefault (Html.text "")
                    )
        , sorter = Table.decreasingOrIncreasingBy (.sport >> Maybe.map Model.sportToString >> Maybe.withDefault "")
        }
    ]


editNewEvent : Year -> Event -> Element Msg
editNewEvent currentYear newEvent =
    row [ UI.largeSpacing ]
        [ Common.yearSelector False currentYear SelectedAYear
        , Common.competitionSelector SelectedACompetition
        , Utils.viewIf (newEvent.competition == WorldChampionships) <| Common.sportSelector False Nothing
        , UI.textInput []
            { onChange = UpdatedNewEventPlace
            , label = Nothing
            , text = newEvent.place
            , placeholder = Just <| Input.placeholder [ Font.italic ] <| text "Lieu"
            }
        , text "Valider"
            |> Button.makeButton (Just SaveNewEvent)
            |> Button.withFontColor Color.green
            |> Button.viewButton
        , text "Annuler"
            |> Button.makeButton (Just CancelledNewEvent)
            |> Button.withFontColor Color.red
            |> Button.viewButton
        ]
