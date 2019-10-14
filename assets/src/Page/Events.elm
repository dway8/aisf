module Page.Events exposing (init, view)

import Api
import Common
import Element exposing (..)
import Html
import Html.Attributes as HA
import Model exposing (Event, EventsPageModel, Msg(..))
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI


init : ( EventsPageModel, Cmd Msg )
init =
    ( { events = Loading
      , tableState = Table.initialSort "ANNÉE"
      }
    , Api.getEvents
    )


view : EventsPageModel -> Element Msg
view model =
    column [ UI.largeSpacing ]
        [ case model.events of
            Success events ->
                events
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el []

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
        { toId = Model.getId
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
    , Common.sportColumn
    ]
