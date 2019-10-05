module Api exposing (createChampion, getChampion, getChampions, getChampionsWithMedals, getMembers, getSectors, updateChampion)

import Aisf.InputObject
import Aisf.Mutation as Mutation
import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Object.Medal as Medal
import Aisf.Object.ProExperience as ProExperience
import Aisf.Object.Sector as Sector
import Aisf.Query as Query
import Aisf.Scalar exposing (Id(..))
import Dict
import Editable
import Graphql.Http
import Graphql.Internal.Builder.Object as Object
import Graphql.OptionalArgument as GOA
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Json.Decode as D
import Model exposing (Attachment, Champion, ChampionForm, Competition(..), Medal, MedalType(..), Msg(..), ProExperience, Sector, Specialty(..), Sport(..), Year(..))
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


getChampionsWithMedals : Cmd Msg
getChampionsWithMedals =
    Query.championsWithMedals championSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampions)


getSectors : Cmd Msg
getSectors =
    Query.sectors sectorSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSectors)


sectorSelection : SelectionSet Sector Aisf.Object.Sector
sectorSelection =
    SelectionSet.succeed Sector
        |> with Sector.id
        |> with Sector.name


championSelection : SelectionSet Champion Aisf.Object.Champion
championSelection =
    SelectionSet.succeed Champion
        |> with Champion.id
        |> with Champion.lastName
        |> with Champion.firstName
        |> with Champion.email
        |> with Champion.birthDate
        |> with Champion.address
        |> with Champion.phoneNumber
        |> with Champion.website
        |> with (SelectionSet.map (Model.sportFromString >> Maybe.withDefault SkiAlpin) Champion.sport)
        |> with (Champion.proExperiences proExperienceSelection)
        |> with (SelectionSet.map (Maybe.withDefault [] >> List.map Year) Champion.yearsInFrenchTeam)
        |> with (Champion.medals medalSelection)
        |> with Champion.isMember
        |> with Champion.intro
        |> with (SelectionSet.map (Maybe.withDefault []) Champion.highlights)
        |> with (SelectionSet.map (Maybe.map (\f -> Attachment f Nothing)) Champion.profilePictureFilename)
        |> with Champion.frenchTeamParticipation
        |> with Champion.olympicGamesParticipation
        |> with Champion.worldCupParticipation
        |> with Champion.trackRecord
        |> with Champion.bestMemory
        |> with Champion.decoration
        |> with Champion.background
        |> with Champion.volunteering
        |> with (SelectionSet.map (Maybe.map (String.fromInt >> Id)) Champion.oldId)


proExperienceSelection : SelectionSet ProExperience Aisf.Object.ProExperience
proExperienceSelection =
    SelectionSet.succeed ProExperience
        |> with ProExperience.id
        |> with ProExperience.title
        |> with ProExperience.companyName
        |> with ProExperience.description
        |> with ProExperience.website
        |> with ProExperience.contact
        |> with (ProExperience.sectors Sector.name)


medalSelection : SelectionSet Medal Aisf.Object.Medal
medalSelection =
    SelectionSet.map5 Medal
        Medal.id
        (SelectionSet.map (Model.competitionFromString >> Maybe.withDefault OlympicGames) Medal.competition)
        (SelectionSet.map Year Medal.year)
        (SelectionSet.map (Model.specialtyFromString >> Maybe.withDefault Slalom) Medal.specialty)
        (SelectionSet.map (Model.medalTypeFromInt >> Maybe.withDefault Bronze) Medal.medalType)


createChampion : Champion -> Cmd Msg
createChampion c =
    Mutation.createChampion (\optional -> optional)
        { firstName = c.firstName
        , lastName = c.lastName
        , sport = Model.sportToString c.sport
        , proExperiences = c.proExperiences |> List.map proExperienceToParams
        , yearsInFrenchTeam = c.yearsInFrenchTeam |> List.map Model.getYear
        , medals = c.medals |> List.map medalToParams
        , isMember = c.isMember
        }
        championSelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveChampionResponse)


updateChampion : Champion -> Cmd Msg
updateChampion ({ firstName, lastName, email, sport, proExperiences, yearsInFrenchTeam, medals, isMember, intro } as champion) =
    Mutation.updateChampion
        (\optional ->
            { optional
                | email = champion.email |> GOA.fromMaybe
                , intro = champion.intro |> GOA.fromMaybe
                , profilePicture = champion.profilePicture |> GOA.fromMaybe |> GOA.map fileToParams
                , frenchTeamParticipation = champion.frenchTeamParticipation |> GOA.fromMaybe
                , olympicGamesParticipation = champion.olympicGamesParticipation |> GOA.fromMaybe
                , worldCupParticipation = champion.worldCupParticipation |> GOA.fromMaybe
                , trackRecord = champion.trackRecord |> GOA.fromMaybe
                , bestMemory = champion.bestMemory |> GOA.fromMaybe
                , decoration = champion.decoration |> GOA.fromMaybe
                , background = champion.background |> GOA.fromMaybe
                , volunteering = champion.volunteering |> GOA.fromMaybe
            }
        )
        { id = Model.getId champion
        , firstName = firstName
        , lastName = lastName
        , sport = Model.sportToString sport
        , proExperiences = proExperiences |> List.map proExperienceToParams
        , yearsInFrenchTeam = yearsInFrenchTeam |> List.map Model.getYear
        , medals = medals |> List.map medalToParams
        , isMember = isMember
        }
        championSelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveChampionResponse)


proExperienceToParams : ProExperience -> Aisf.InputObject.ProExperienceParams
proExperienceToParams ({ id, title, companyName, description, website, contact, sectors } as proExp) =
    { id = Model.getId proExp
    , title = title |> GOA.fromMaybe
    , companyName = companyName |> GOA.fromMaybe
    , description = description |> GOA.fromMaybe
    , website = website |> GOA.fromMaybe
    , contact = contact |> GOA.fromMaybe
    , sectors = sectors
    }


medalToParams : Medal -> Aisf.InputObject.MedalParams
medalToParams ({ competition, year, specialty, medalType } as medal) =
    { id = Model.getId medal
    , competition = Model.competitionToString competition
    , year = Model.getYear year
    , specialty = Model.specialtyToString specialty
    , medalType = Model.medalTypeToInt medalType
    }


fileToParams : Attachment -> Aisf.InputObject.FileParams
fileToParams { base64, filename } =
    { base64 = base64 |> GOA.fromMaybe
    , filename = filename
    }
