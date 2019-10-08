module Page.Admin exposing (init, view)

import Api
import Common
import Element exposing (..)
import Graphql.Http
import Html
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (AdminPageModel, Champion, Msg(..), Sector, Sectors, Sport)
import RemoteData exposing (RemoteData(..), WebData)
import Table
import UI
import UI.Button as Button
import UI.Color


init : ( AdminPageModel, Cmd Msg )
init =
    ( { champions = Loading
      , sport = Nothing
      , tableState = Table.sortBy "NOM / PRÉNOM" True
      , searchQuery = Nothing
      , sector = Nothing
      }
    , Api.getChampions
    )


view : RemoteData (Graphql.Http.Error Sectors) Sectors -> AdminPageModel -> Element Msg
view rdSectors model =
    column [ UI.largeSpacing, width fill ]
        [ row [ UI.defaultSpacing, width fill ]
            [ Common.viewSearchQuery model.searchQuery
            , Common.sportSelector True model.sport
            , sectorSelector rdSectors model.sector
            ]
        , link []
            { url = "/champions/new"
            , label =
                text "Ajouter un champion"
                    |> Button.makeButton Nothing
                    |> Button.withBackgroundColor UI.Color.green
                    |> Button.viewButton
            }
        , case model.champions of
            Success champions ->
                champions
                    |> Common.filterBySearchQuery model.searchQuery
                    |> filterBySport model.sport
                    |> filterBySector model.sector
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


filterBySector : Maybe Sector -> List Champion -> List Champion
filterBySector sector champions =
    case sector of
        Nothing ->
            champions

        Just { name } ->
            champions
                |> List.filter (.proExperiences >> List.any (\exp -> exp.sectors |> List.any ((==) name)))


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
    , Table.veryCustomColumn
        { name = "DISCIPLINE"
        , viewData = \champion -> Common.defaultCell [] (Html.text <| Model.sportToString champion.sport)
        , sorter = Table.decreasingOrIncreasingBy (.sport >> Model.sportToString)
        }
    ]


sectorSelector : RemoteData (Graphql.Http.Error Sectors) Sectors -> Maybe Sector -> Element Msg
sectorSelector rdSectors currentSector =
    case rdSectors of
        Success sectors ->
            let
                list =
                    [ "Tous les secteurs d'activité" ]
                        ++ List.map .name sectors
            in
            el [] <|
                html <|
                    Html.select
                        [ HE.on "change" <| D.map SelectedASector <| HE.targetValue
                        , HA.style "font-family" "Open Sans"
                        , HA.style "font-size" "15px"
                        , HA.id "sector-selector"
                        ]
                        (List.map (viewSectorOption sectors currentSector) list)

        _ ->
            none


viewSectorOption : Sectors -> Maybe Sector -> String -> Html.Html msg
viewSectorOption sectors currentSector sectorName =
    Html.option
        [ HA.value sectorName
        , HA.selected <| currentSector == Model.findSectorByName sectors sectorName
        ]
        [ Html.text sectorName ]
