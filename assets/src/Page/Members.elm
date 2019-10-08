module Page.Members exposing (init, view)

import Api
import Common
import Element exposing (..)
import Html
import Html.Attributes as HA
import Model exposing (Champion, MembersPageModel, Msg(..), Sport)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI


init : ( MembersPageModel, Cmd Msg )
init =
    ( { champions = Loading
      , sport = Nothing
      , tableState = Table.sortBy "NOM / PRÉNOM" True
      , searchQuery = Nothing
      }
    , Api.getMembers
    )


view : MembersPageModel -> Element Msg
view model =
    column [ UI.largeSpacing ]
        [ row [ UI.largeSpacing ] [ Common.viewSearchQuery model.searchQuery, Common.sportSelector True model.sport ]
        , case model.champions of
            Success champions ->
                champions
                    |> Common.filterBySearchQuery model.searchQuery
                    |> filterBySport model.sport
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el []

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
    [ Common.profilePictureColumn
    , Common.nameColumn
    , Common.sportColumn
    ]
