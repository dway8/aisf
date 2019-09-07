module Api exposing (createChampion, getChampion, getChampions)

import Aisf.Mutation as Mutation
import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Object.Medal as Medal
import Aisf.Object.ProExperience as ProExperience
import Aisf.Object.Sport as Sport
import Aisf.Query as Query
import Aisf.Scalar exposing (Id(..))
import Graphql.Http
import Graphql.Internal.Builder.Object as Object
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Json.Decode as D
import Model exposing (Champion, Competition(..), Medal, MedalType(..), Msg(..), ProExperience, Specialty(..), Sport(..))
import RemoteData


endpoint : String
endpoint =
    "/graphql"


getChampions : Cmd Msg
getChampions =
    Query.allChampions championSelection
        |> Graphql.Http.queryRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampions)


getChampion : Id -> Cmd Msg
getChampion id =
    Query.champion { id = id } championSelection
        |> Graphql.Http.queryRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampion)


championSelection : SelectionSet Champion Aisf.Object.Champion
championSelection =
    SelectionSet.map8 Champion
        Champion.id
        Champion.lastName
        Champion.firstName
        Champion.email
        (SelectionSet.map (Model.sportFromString >> Maybe.withDefault SkiAlpin) (Champion.sport Sport.name))
        (Champion.proExperiences proExperienceSelection)
        (SelectionSet.map (Maybe.withDefault []) Champion.yearsInFrenchTeam)
        (Champion.medals medalSelection)


proExperienceSelection : SelectionSet ProExperience Aisf.Object.ProExperience
proExperienceSelection =
    SelectionSet.map6 ProExperience
        ProExperience.occupationalCategory
        ProExperience.title
        ProExperience.companyName
        ProExperience.description
        ProExperience.website
        ProExperience.contact


medalSelection : SelectionSet Medal Aisf.Object.Medal
medalSelection =
    SelectionSet.map4 Medal
        (SelectionSet.map (Model.competitionFromString >> Maybe.withDefault OlympicGames) Medal.competition)
        Medal.year
        (SelectionSet.map (Model.specialtyFromString >> Maybe.withDefault Slalom) Medal.specialty)
        (SelectionSet.map (Model.medalTypeFromInt >> Maybe.withDefault Bronze) Medal.medalType)


sportDecoder : D.Decoder (Maybe Sport)
sportDecoder =
    D.succeed (Just SkiAlpin)


createChampion : Champion -> Cmd Msg
createChampion { firstName, lastName, email, sport, proExperiences, yearsInFrenchTeam } =
    Mutation.createChampion
        { email = email
        , firstName = firstName
        , lastName = lastName
        , sport = Model.sportToString sport
        , proExperiences = proExperiences
        , yearsInFrenchTeam = yearsInFrenchTeam
        }
        championSelection
        |> Graphql.Http.mutationRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotCreateChampionResponse)
