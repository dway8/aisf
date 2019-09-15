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


parseUrl : Url -> Route
parseUrl url =
    url
        |> parse
            (oneOf
                [ map MembersRoute top
                , map MembersRoute (s "champions")
                , map MedalsRoute (s "medals")
                , map TeamsRoute (s "teams")
                , map (EditChampionRoute Nothing) (s "champions" </> s "new")
                , map (\intId -> EditChampionRoute <| Just <| Id (String.fromInt intId)) (s "champions" </> s "edit" </> int)
                , map (\intId -> ChampionRoute <| Id (String.fromInt intId)) (s "champions" </> int)
                , map AdminRoute (s "admin")
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

        EditChampionRoute (Just (Id id)) ->
            "/champions/edit/" ++ id

        EditChampionRoute Nothing ->
            "/champions/new"

        AdminRoute ->
            "/admin"
