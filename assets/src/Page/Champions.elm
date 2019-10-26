module Page.Champions exposing (init, view)

import Common
import Dict exposing (Dict)
import Element exposing (..)
import Graphql.Http
import Html
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as D
import Model exposing (Champion, Champions, ChampionsPageModel, Msg(..), Sector, Sectors, Sport)
import RemoteData exposing (RemoteData(..), WebData)
import Route exposing (Route(..))
import Table
import UI
import UI.Button as Button
import UI.Color as Color
import Utils


init : ( ChampionsPageModel, Cmd Msg )
init =
    ( { sport = Nothing
      , tableState = Table.sortBy "NOM / PRÉNOM" True
      , searchQuery = Nothing
      , sector = Nothing
      }
    , Cmd.none
    )


view : Bool -> RemoteData (Graphql.Http.Error Champions) Champions -> RemoteData (Graphql.Http.Error Sectors) Sectors -> ChampionsPageModel -> Element Msg
view isAdmin rdChampions rdSectors model =
    column [ UI.largeSpacing, width fill ]
        [ row [ UI.largeSpacing ]
            [ Common.viewSearchQuery model.searchQuery
            , Common.sportSelector True model.sport
            , Utils.viewIf isAdmin <| sectorSelector rdSectors model.sector
            ]
        , Utils.viewIf isAdmin <|
            link []
                { url = Route.routeToString <| EditChampionRoute Nothing
                , label =
                    row [ UI.defaultSpacing ] [ el [] <| UI.viewIcon "plus", text "Ajouter un champion" ]
                        |> Button.makeButton Nothing
                        |> Button.withBackgroundColor Color.green
                        |> Button.viewButton
                }
        , case rdChampions of
            Success champions ->
                champions
                    |> Common.filterBySearchQuery model.searchQuery
                    |> filterBySport model.sport
                    |> (if isAdmin then
                            filterBySector model.sector

                        else
                            identity
                       )
                    |> Table.view tableConfig model.tableState
                    |> html
                    |> el [ htmlAttribute <| HA.id "champions-list", width fill ]

            NotAsked ->
                none

            Loading ->
                UI.spinner

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
            Common.tableCustomizations attrsForHeaders
    in
    Table.customConfig
        { toId = Model.getId
        , toMsg = TableMsg
        , columns = tableColumns
        , customizations = { tableCustomizations | rowAttrs = Common.toRowAttrs }
        }


attrsForHeaders : Dict String (List (Html.Attribute msg))
attrsForHeaders =
    Dict.fromList <|
        [ ( "MEMBRE", [ HA.style "text-align" "center" ] )
        , ( "DISCIPLINE", [ HA.style "text-align" "center" ] )
        ]


tableColumns : List (Table.Column Champion Msg)
tableColumns =
    [ Common.profilePictureColumn
    , Common.memberColumn
    , Common.nameColumn
    , Common.sportColumn
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
