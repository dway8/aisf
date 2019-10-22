module Route exposing (Route(..), parseUrl, routeToString)

import Aisf.Scalar exposing (Id(..))
import Model
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


type Route
    = ChampionsRoute
    | MedalsRoute
    | TeamsRoute
    | ChampionRoute Id
    | EditChampionRoute (Maybe Id)
    | EventsRoute
    | RecordsRoute
    | LoginRoute


parseUrl : Url -> Route
parseUrl url =
    url
        |> parse
            (s "elixir"
                </> oneOf
                        [ map ChampionsRoute top
                        , map ChampionsRoute (s "champions")
                        , map MedalsRoute (s "medals")
                        , map TeamsRoute (s "teams")
                        , map (EditChampionRoute Nothing) (s "champions" </> s "new")
                        , map (\intId -> EditChampionRoute <| Just <| Id (String.fromInt intId)) (s "champions" </> s "edit" </> int)
                        , map (\intId -> ChampionRoute <| Id (String.fromInt intId)) (s "champions" </> int)
                        , map EventsRoute (s "events")
                        , map RecordsRoute (s "records")
                        , map LoginRoute (s "login")
                        ]
            )
        |> Maybe.withDefault ChampionsRoute


routeToString : Route -> String
routeToString route =
    Model.baseEndpoint
        ++ (case route of
                ChampionsRoute ->
                    "/champions"

                MedalsRoute ->
                    "/medals"

                TeamsRoute ->
                    "/teams"

                ChampionRoute (Id id) ->
                    "/champions/" ++ id

                EditChampionRoute (Just (Id id)) ->
                    "/champions/edit/" ++ id

                EditChampionRoute Nothing ->
                    "/champions/new"

                EventsRoute ->
                    "/events"

                RecordsRoute ->
                    "/records"

                LoginRoute ->
                    "/login"
           )
