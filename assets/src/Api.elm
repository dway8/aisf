module Api exposing (getChampions)

import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Query as Query
import Graphql.Http
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Model exposing (Champion, Msg(..))
import RemoteData


endpoint : String
endpoint =
    "/graphql"


getChampions : Cmd Msg
getChampions =
    Query.allChampions championInfoSelection
        |> Graphql.Http.queryRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampions)


championInfoSelection : SelectionSet Champion Aisf.Object.Champion
championInfoSelection =
    SelectionSet.map2 Champion
        Champion.lastName
        Champion.firstName
