module Api exposing (createChampion, createEvent, createRecord, getChampion, getChampions, getChampionsWithMedals, getEvents, getRecords, getSectors, login, updateChampion)

import Aisf.InputObject
import Aisf.Mutation as Mutation
import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Object.Event as Event
import Aisf.Object.LoginResponse as LoginResponse
import Aisf.Object.Medal as Medal
import Aisf.Object.Picture as Picture
import Aisf.Object.ProExperience as ProExperience
import Aisf.Object.Record as Record
import Aisf.Object.Sector as Sector
import Aisf.Object.Winner as Winner
import Aisf.Query as Query
import Aisf.Scalar exposing (Id(..))
import Dict
import Graphql.Http
import Graphql.Internal.Builder.Object as Object
import Graphql.OptionalArgument as GOA
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Json.Decode as D
import Model exposing (Attachment, Champion, ChampionForm, Competition(..), Event, LoginResponse(..), Medal, MedalType(..), Msg(..), Picture, ProExperience, Record, RecordType(..), Sector, Specialty(..), Sport(..), Winner, Year(..))
import RemoteData


endpoint : String
endpoint =
    Model.baseEndpoint ++ "/graphql"


getChampions : Cmd Msg
getChampions =
    Query.champions (championSelection False)
        |> Graphql.Http.queryRequest endpoint
        -- We have to use `withCredentials` to support a CORS endpoint that allows a wildcard origin
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampions)


getChampion : Bool -> Id -> Cmd Msg
getChampion isAdmin id =
    Query.champion { id = id } (championSelection isAdmin)
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotChampion)


getChampionsWithMedals : Cmd Msg
getChampionsWithMedals =
    Query.championsWithMedals (championSelection False)
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


championSelection : Bool -> SelectionSet Champion Aisf.Object.Champion
championSelection isAdmin =
    SelectionSet.succeed Champion
        |> with Champion.id
        |> with Champion.lastName
        |> with Champion.firstName
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
        |> with (Champion.pictures pictureSelection)
        |> (if isAdmin then
                with Champion.birthDate
                    >> with Champion.email
                    >> with Champion.address
                    >> with Champion.phoneNumber
                    >> with Champion.login

            else
                SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
           )


pictureSelection : SelectionSet Picture Aisf.Object.Picture
pictureSelection =
    SelectionSet.succeed Picture
        |> with Picture.id
        |> with (SelectionSet.map (\f -> Attachment f Nothing) Picture.filename)


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
createChampion champion =
    Mutation.createChampion
        (fillInChampionOptionalArgs champion)
        { firstName = champion.firstName
        , lastName = champion.lastName
        , sport = Model.sportToString champion.sport
        , proExperiences = champion.proExperiences |> List.map proExperienceToParams
        , yearsInFrenchTeam = champion.yearsInFrenchTeam |> List.map Model.getYear
        , medals = champion.medals |> List.map medalToParams
        , isMember = champion.isMember
        , highlights = champion.highlights
        , pictures = champion.pictures |> List.map pictureToParams
        }
        (championSelection True)
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveChampionResponse)


updateChampion : Champion -> Cmd Msg
updateChampion ({ firstName, lastName, email, sport, proExperiences, yearsInFrenchTeam, medals, isMember, intro } as champion) =
    Mutation.updateChampion
        (fillInChampionOptionalArgs champion)
        { id = Model.getId champion
        , firstName = firstName
        , lastName = lastName
        , sport = Model.sportToString sport
        , proExperiences = proExperiences |> List.map proExperienceToParams
        , yearsInFrenchTeam = yearsInFrenchTeam |> List.map Model.getYear
        , medals = medals |> List.map medalToParams
        , isMember = isMember
        , highlights = champion.highlights
        , pictures = champion.pictures |> List.map pictureToParams
        }
        (championSelection True)
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveChampionResponse)


fillInChampionOptionalArgs : Champion -> Mutation.UpdateChampionOptionalArguments -> Mutation.UpdateChampionOptionalArguments
fillInChampionOptionalArgs champion optional =
    { optional
        | intro = champion.intro |> GOA.fromMaybe
        , profilePicture = champion.profilePicture |> GOA.fromMaybe |> GOA.map fileToParams
        , frenchTeamParticipation = champion.frenchTeamParticipation |> GOA.fromMaybe
        , olympicGamesParticipation = champion.olympicGamesParticipation |> GOA.fromMaybe
        , worldCupParticipation = champion.worldCupParticipation |> GOA.fromMaybe
        , trackRecord = champion.trackRecord |> GOA.fromMaybe
        , bestMemory = champion.bestMemory |> GOA.fromMaybe
        , decoration = champion.decoration |> GOA.fromMaybe
        , background = champion.background |> GOA.fromMaybe
        , volunteering = champion.volunteering |> GOA.fromMaybe
        , birthDate = champion.birthDate |> GOA.fromMaybe
        , address = champion.address |> GOA.fromMaybe
        , email = champion.email |> GOA.fromMaybe
        , phoneNumber = champion.phoneNumber |> GOA.fromMaybe
    }


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


pictureToParams : Picture -> Aisf.InputObject.PictureParams
pictureToParams picture =
    { id = Model.getId picture
    , attachment = picture.attachment |> fileToParams
    }


fileToParams : Attachment -> Aisf.InputObject.FileParams
fileToParams { base64, filename } =
    { base64 = base64 |> GOA.fromMaybe
    , filename = filename
    }


getEvents : Cmd Msg
getEvents =
    Query.events eventSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotEvents)


eventSelection : SelectionSet Event Aisf.Object.Event
eventSelection =
    SelectionSet.succeed Event
        |> with (SelectionSet.map (Model.competitionFromString >> Maybe.withDefault OlympicGames) Event.competition)
        |> with (SelectionSet.map (Maybe.andThen Model.sportFromString) Event.sport)
        |> with (SelectionSet.map Year Event.year)
        |> with Event.place


createEvent : Event -> Cmd Msg
createEvent event =
    Mutation.createEvent (\optional -> { optional | sport = event.sport |> Maybe.map Model.sportToString |> GOA.fromMaybe })
        { competition = Model.competitionToString event.competition
        , year = Model.getYear event.year
        , place = event.place
        }
        eventSelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveEventResponse)


getRecords : Cmd Msg
getRecords =
    Query.records recordSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotRecords)


recordSelection : SelectionSet Record Aisf.Object.Record
recordSelection =
    SelectionSet.succeed Record
        |> with (SelectionSet.map (Model.recordTypeFromInt >> Maybe.withDefault Triple) Record.recordType)
        |> with (SelectionSet.map Year Record.year)
        |> with Record.place
        |> with (SelectionSet.map (Model.specialtyFromString >> Maybe.withDefault Slalom) Record.specialty)
        |> with (SelectionSet.map Dict.fromList (Record.winners winnerSelection))


winnerSelection : SelectionSet ( Int, Winner ) Aisf.Object.Winner
winnerSelection =
    SelectionSet.succeed (\l f p -> ( p, Winner l f ))
        |> with Winner.lastName
        |> with Winner.firstName
        |> with Winner.position


createRecord : Record -> Cmd Msg
createRecord record =
    Mutation.createRecord
        { recordType = Model.recordTypeToInt record.recordType
        , year = Model.getYear record.year
        , place = record.place
        , specialty = Model.specialtyToString record.specialty
        , winners = record.winners |> Dict.toList |> List.map winnerToParams
        }
        recordSelection
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveRecordResponse)


winnerToParams : ( Int, Winner ) -> Aisf.InputObject.WinnerParams
winnerToParams ( index, winner ) =
    { lastName = winner.lastName
    , firstName = winner.firstName
    , position = index
    }


login : String -> String -> Cmd Msg
login lastName loginId =
    Query.login { lastName = lastName, loginId = loginId } loginResponseSelection
        |> Graphql.Http.queryRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotLoginResponse)


loginResponseSelection : SelectionSet LoginResponse Aisf.Object.LoginResponse
loginResponseSelection =
    SelectionSet.succeed
        (\result maybeId ->
            case ( result, maybeId ) of
                ( True, Just id ) ->
                    Authorized id

                _ ->
                    Denied
        )
        |> with LoginResponse.result
        |> with LoginResponse.id
