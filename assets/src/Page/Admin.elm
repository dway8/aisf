module Page.Admin exposing (init, view)

import Api
import Common
import Element exposing (..)
import Html
import Html.Attributes as HA
import Model exposing (AdminPageModel, Champion, Msg(..), Sport)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI


init : ( AdminPageModel, Cmd Msg )
init =
    ( { champions = Loading
      , sport = Nothing
      , tableState = Table.sortBy "NOM / PRÉNOM" True
      , searchQuery = Nothing
      }
    , Api.getChampions
    )


view : AdminPageModel -> Element Msg
view model =
    column [ UI.largeSpacing ]
        [ row [ UI.defaultSpacing ]
            [ Common.viewSearchQuery model.searchQuery
            , Common.sportSelector True model.sport
            ]
        , link [] { url = "/champions/new", label = el [] <| text "Ajouter champion" }
        , case model.champions of
            Success champions ->
                champions
                    |> Common.filterBySearchQuery model.searchQuery
                    |> filterBySport model.sport
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el [ htmlAttribute <| HA.id "admin-list" ]

            NotAsked ->
                none

            Loading ->
                text "..."

            _ ->
                text "Une erreur s'est produite."
        ]


filterBySport : Maybe Sport -> List Champion -> List Champion
filterBySport sport champions =
    case sport of
        Nothing ->
            champions

        Just s ->
            champions
                |> List.filter (.sport >> (==) s)


tableConfig : Table.Config Champion Msg
tableConfig =
    let
        tableCustomizations =
            Common.tableCustomizations
    in
    Table.customConfig
        { toId = Model.getId
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = Common.toRowAttrs }
        }


tableColumns : List (Table.Column Champion Msg)
tableColumns =
    [ Table.veryCustomColumn
        { name = "NOM / PRÉNOM"
        , viewData = \champion -> Common.defaultCell [] (Html.text <| Model.getName champion)
        , sorter = Table.decreasingOrIncreasingBy .lastName
        }
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData = \champion -> Common.defaultCell [] (Html.text <| Model.sportToString champion.sport)
        , sorter = Table.decreasingOrIncreasingBy (.sport >> Model.sportToString)
        }
    ]
