module Api exposing (getChampions)

import Graphql.Http
import Model exposing (Msg(..))
import Queries


getChampions : String ->  Cmd Msg
getChampions endpoint  =

Query.hero identity championInfoSelection
 |> Graphql.Http.queryRequest "/api"

        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampions)

championInfoSelection : SelectionSet Character Swapi.Interface.Character
characterInfoSelection =
    SelectionSet.map3 Character
        Character.name
        Character.id
        (Character.friends Character.name)
