module Api exposing (createChampion, getChampion, getChampions)

import Aisf.Mutation as Mutation
import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Object.Sport as Sport
import Aisf.Query as Query
import Aisf.Scalar exposing (Id(..))
import Graphql.Http
import Graphql.Internal.Builder.Object as Object
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Json.Decode as D
import Model exposing (Champion, Msg(..), Sport(..))
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
    SelectionSet.map5 (\id l f e s -> Champion id l f e (s |> Maybe.map sportFromString))
        Champion.id
        Champion.lastName
        Champion.firstName
        Champion.email
        (Champion.sport Sport.name)


sportDecoder : D.Decoder (Maybe Sport)
sportDecoder =
    D.succeed (Just SkiAlpin)


sportFromString : String -> Sport
sportFromString str =
    case str of
        "Ski alpin" ->
            SkiAlpin

        "Ski de fond" ->
            SkiDeFond

        _ ->
            Saut


createChampion : Champion -> Cmd Msg
createChampion { firstName, lastName, email } =
    Mutation.createChampion { email = email, firstName = firstName, lastName = lastName } championInfoSelection
        |> Graphql.Http.mutationRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotCreateChampionResponse)
