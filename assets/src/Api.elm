module Api exposing (createChampion, getChampion, getChampions)

import Aisf.Mutation as Mutation
import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Query as Query
import Aisf.Scalar exposing (Id(..))
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


getChampion : Id -> Cmd Msg
getChampion id =
    Query.champion { id = id } championInfoSelection
        |> Graphql.Http.queryRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampion)


championInfoSelection : SelectionSet Champion Aisf.Object.Champion
championInfoSelection =
    SelectionSet.map4 Champion
        Champion.id
        Champion.lastName
        Champion.firstName
        Champion.email


createChampion : Champion -> Cmd Msg
createChampion { firstName, lastName, email } =
    Mutation.createChampion { email = email, firstName = firstName, lastName = lastName } championInfoSelection
        |> Graphql.Http.mutationRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotCreateChampionResponse)
