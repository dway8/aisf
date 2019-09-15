module Route exposing (Route(..), parseUrl, routeToString)

import Aisf.Scalar exposing (Id(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)


type Route
    = MembersRoute
    | MedalsRoute
    | TeamsRoute
    | ChampionRoute Id
    | NewChampionRoute


parseUrl : Url -> Route
parseUrl url =
    url
        |> parse
            (oneOf
                [ map MembersRoute top
                , map MembersRoute (s "champions")
                , map MedalsRoute (s "medals")
                , map TeamsRoute (s "teams")
                , map NewChampionRoute (s "champions" </> s "new")
                , map (\intId -> ChampionRoute <| Id (String.fromInt intId)) (s "champions" </> int)
                ]
            )
        |> Maybe.withDefault MembersRoute


routeToString : Route -> String
routeToString route =
    case route of
        MembersRoute ->
            "/champions"

        MedalsRoute ->
            "/medals"

        TeamsRoute ->
            "/teams"

        ChampionRoute (Id id) ->
            "/champions/" ++ id

        NewChampionRoute ->
            "/champions/new"
