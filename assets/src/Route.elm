module Route exposing (Route(..), parseUrl, routeToString)

import Aisf.Scalar exposing (Id(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, string, top)


type Route
    = MembersRoute
    | MedalsRoute
    | TeamsRoute
    | ChampionRoute Id
    | EditChampionRoute (Maybe Id)
    | AdminRoute
    | EventsRoute


parseUrl : Url -> Route
parseUrl url =
    url
        |> parse
            (oneOf
                [ map MembersRoute (s "elixir")
                , map MembersRoute (s "elixir" </> s "champions")
                , map MedalsRoute (s "elixir" </> s "medals")
                , map TeamsRoute (s "elixir" </> s "teams")
                , map (EditChampionRoute Nothing) (s "elixir" </> s "champions" </> s "new")
                , map (\intId -> EditChampionRoute <| Just <| Id (String.fromInt intId)) (s "elixir" </> s "champions" </> s "edit" </> int)
                , map (\intId -> ChampionRoute <| Id (String.fromInt intId)) (s "elixir" </> s "champions" </> int)
                , map AdminRoute (s "elixir" </> s "admin")
                , map EventsRoute (s "elixir" </> s "events")
                ]
            )
        |> Maybe.withDefault MembersRoute


routeToString : Route -> String
routeToString route =
    "/elixir"
        ++ (case route of
                MembersRoute ->
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

                AdminRoute ->
                    "/admin"

                EventsRoute ->
                    "/events"
           )
