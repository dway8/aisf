module Api exposing (createChampion, getChampion, getChampions, getChampionsWithMedalInSport, getMembers, updateChampion)

import Aisf.InputObject
import Aisf.Mutation as Mutation
import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Object.Medal as Medal
import Aisf.Object.ProExperience as ProExperience
import Aisf.Query as Query
import Aisf.Scalar exposing (Id(..))
import Dict
import Editable
import Graphql.Http
import Graphql.Internal.Builder.Object as Object
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Json.Decode as D
import Model exposing (Champion, ChampionForm, Competition(..), Medal, MedalType(..), Msg(..), ProExperience, Specialty(..), Sport(..), Year(..))
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


getMembers : Cmd Msg
getMembers =
    Query.getMembers championSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampions)


getChampion : Id -> Cmd Msg
getChampion id =
    Query.champion { id = id } championSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampion)


getChampionsWithMedalInSport : Sport -> Cmd Msg
getChampionsWithMedalInSport sport =
    Query.championsWithMedalInSport { sport = Model.sportToString sport } championSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampions)


championSelection : SelectionSet Champion Aisf.Object.Champion
championSelection =
    SelectionSet.succeed Champion
        |> with Champion.id
        |> with Champion.lastName
        |> with Champion.firstName
        |> with Champion.email
        |> with (SelectionSet.map (Model.sportFromString >> Maybe.withDefault SkiAlpin) Champion.sport)
        |> with (Champion.proExperiences proExperienceSelection)
        |> with (SelectionSet.map (Maybe.withDefault [] >> List.map Year) Champion.yearsInFrenchTeam)
        |> with (Champion.medals medalSelection)
        |> with Champion.isMember
        |> with Champion.intro


proExperienceSelection : SelectionSet ProExperience Aisf.Object.ProExperience
proExperienceSelection =
    SelectionSet.map7 ProExperience
        ProExperience.id
        ProExperience.occupationalCategory
        ProExperience.title
        ProExperience.companyName
        ProExperience.description
        ProExperience.website
        ProExperience.contact


medalSelection : SelectionSet Medal Aisf.Object.Medal
medalSelection =
    SelectionSet.map5 Medal
        Medal.id
        (SelectionSet.map (Model.competitionFromString >> Maybe.withDefault OlympicGames) Medal.competition)
        (SelectionSet.map Year Medal.year)
        (SelectionSet.map (Model.specialtyFromString >> Maybe.withDefault Slalom) Medal.specialty)
        (SelectionSet.map (Model.medalTypeFromInt >> Maybe.withDefault Bronze) Medal.medalType)


createChampion : Champion -> Cmd Msg
createChampion { firstName, lastName, email, sport, proExperiences, yearsInFrenchTeam, medals, isMember, intro } =
    Mutation.createChampion
        { email = email
        , firstName = firstName
        , lastName = lastName
        , sport = Model.sportToString sport
        , proExperiences = proExperiences |> List.map proExperienceToParams
        , yearsInFrenchTeam = yearsInFrenchTeam |> List.map Model.getYear
        , medals = medals |> List.map medalToParams
        , isMember = isMember
        , intro = intro
        }
        championSelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveChampionResponse)


updateChampion : Champion -> Cmd Msg
updateChampion ({ firstName, lastName, email, sport, proExperiences, yearsInFrenchTeam, medals, isMember, intro } as champion) =
    Mutation.updateChampion
        { id = Model.getId champion
        , email = email
        , firstName = firstName
        , lastName = lastName
        , sport = Model.sportToString sport
        , proExperiences = proExperiences |> List.map proExperienceToParams
        , yearsInFrenchTeam = yearsInFrenchTeam |> List.map Model.getYear
        , medals = medals |> List.map medalToParams
        , isMember = isMember
        , intro = intro
        }
        championSelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveChampionResponse)


proExperienceToParams : ProExperience -> Aisf.InputObject.ProExperienceParams
proExperienceToParams ({ id, occupationalCategory, title, companyName, description, website, contact } as proExp) =
    { id = Model.getId proExp
    , occupationalCategory = occupationalCategory
    , title = title
    , companyName = companyName
    , description = description
    , website = website
    , contact = contact
    }


medalToParams : Medal -> Aisf.InputObject.MedalParams
medalToParams ({ competition, year, specialty, medalType } as medal) =
    { id = Model.getId medal
    , competition = Model.competitionToString competition
    , year = Model.getYear year
    , specialty = Model.specialtyToString specialty
    , medalType = Model.medalTypeToInt medalType
    }
