module Api exposing (createChampion, createEvent, createRecord, getChampion, getChampions, getEvents, getRecords, getSectors, login, updateChampion)

import Aisf.InputObject
import Aisf.Mutation as Mutation
import Aisf.Object
import Aisf.Object.Champion as Champion
import Aisf.Object.ChampionLite as ChampionLite
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
import Editable exposing (Editable(..))
import Graphql.Http
import Graphql.Internal.Builder.Object as Object
import Graphql.OptionalArgument as GOA
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Json.Decode as D
import Model exposing (..)
import RemoteData
import Route
import Utils


endpoint : String
endpoint =
    Route.baseEndpoint ++ "/graphql"


getChampions : Cmd Msg
getChampions =
    Query.champions (championLiteSelection False)
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
    SelectionSet.succeed (\i p pi sc pc pic m -> Champion i (ReadOnly p) (ReadOnly pi) (ReadOnly sc) (ReadOnly pc) (ReadOnly pic) (ReadOnly m))
        |> with Champion.id
        |> with presentationFragment
        |> with (privateInfoFragment isAdmin)
        |> with sportCareerFragment
        |> with professionalCareerFragment
        |> with (SelectionSet.map Utils.toDict (Champion.pictures pictureSelection))
        |> with (SelectionSet.map Utils.toDict (Champion.medals medalSelection))


championLiteSelection : Bool -> SelectionSet ChampionLite Aisf.Object.ChampionLite
championLiteSelection isAdmin =
    SelectionSet.succeed ChampionLite
        |> with ChampionLite.id
        |> with ChampionLite.lastName
        |> with ChampionLite.firstName
        |> with (SelectionSet.map (Model.sportFromString >> Maybe.withDefault SkiAlpin) ChampionLite.sport)
        |> with ChampionLite.isMember
        |> with (SelectionSet.map (Maybe.map (\f -> Attachment f Nothing)) ChampionLite.profilePictureFilename)
        |> with (SelectionSet.map (Maybe.withDefault [] >> List.map Year) ChampionLite.yearsInFrenchTeam)
        |> with (ChampionLite.medals medalSelection)
        |> with (SelectionSet.map (List.concatMap .sectors) (ChampionLite.proExperiences proExperienceSelection))


presentationFragment : SelectionSet Presentation Aisf.Object.Champion
presentationFragment =
    SelectionSet.succeed Presentation
        |> with Champion.lastName
        |> with Champion.firstName
        |> with (SelectionSet.map (Model.sportFromString >> Maybe.withDefault SkiAlpin) Champion.sport)
        |> with Champion.isMember
        |> with Champion.intro
        |> with (SelectionSet.map (Maybe.map Utils.toDict >> Maybe.withDefault Dict.empty) Champion.highlights)
        |> with (SelectionSet.map (Maybe.map (\f -> Attachment f Nothing)) Champion.profilePictureFilename)


privateInfoFragment : Bool -> SelectionSet PrivateInfo Aisf.Object.Champion
privateInfoFragment isAdmin =
    SelectionSet.succeed PrivateInfo
        |> (if isAdmin then
                with Champion.login
                    >> with Champion.birthDate
                    >> with Champion.address
                    >> with Champion.email
                    >> with Champion.phoneNumber

            else
                SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
                    >> SelectionSet.hardcoded Nothing
           )


sportCareerFragment : SelectionSet SportCareer Aisf.Object.Champion
sportCareerFragment =
    SelectionSet.succeed SportCareer
        |> with Champion.olympicGamesParticipation
        |> with Champion.worldCupParticipation
        |> with Champion.trackRecord
        |> with Champion.bestMemory
        |> with Champion.decoration
        |> with (SelectionSet.map (Maybe.withDefault [] >> List.map Year >> Utils.toDict) Champion.yearsInFrenchTeam)


professionalCareerFragment : SelectionSet ProfessionalCareer Aisf.Object.Champion
professionalCareerFragment =
    SelectionSet.succeed ProfessionalCareer
        |> with Champion.background
        |> with Champion.volunteering
        |> with (SelectionSet.map Utils.toDict (Champion.proExperiences proExperienceSelection))


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
    let
        presentation =
            champion.presentation |> Editable.value
    in
    Mutation.createChampion
        { firstName = presentation.firstName
        , lastName = presentation.lastName
        , sport = Model.sportToString presentation.sport
        , isMember = presentation.isMember
        }
        (championSelection True)
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotCreateChampionResponse)


updateChampion : FormBlock -> Champion -> Cmd Msg
updateChampion block champion =
    let
        mutation =
            case block of
                PresentationBlock ->
                    let
                        p =
                            champion.presentation |> Editable.value
                    in
                    Mutation.updateChampionPresentation
                        (\optional ->
                            { optional
                                | intro = p.intro |> GOA.fromMaybe
                                , profilePicture = p.profilePicture |> GOA.fromMaybe |> GOA.map fileToParams
                            }
                        )
                        { id = Model.getId champion
                        , firstName = p.firstName
                        , lastName = p.lastName
                        , sport = Model.sportToString p.sport
                        , isMember = p.isMember
                        , highlights = p.highlights |> Dict.values
                        }

                PrivateInfoBlock ->
                    let
                        pi =
                            champion.privateInfo |> Editable.value
                    in
                    Mutation.updateChampionPrivateInfo
                        (\optional ->
                            { optional
                                | birthDate = pi.birthDate |> GOA.fromMaybe
                                , address = pi.address |> GOA.fromMaybe
                                , email = pi.email |> GOA.fromMaybe
                                , phoneNumber = pi.phoneNumber |> GOA.fromMaybe
                            }
                        )
                        { id = Model.getId champion }

                SportCareerBlock ->
                    let
                        sc =
                            champion.sportCareer |> Editable.value
                    in
                    Mutation.updateChampionSportCareer
                        (\optional ->
                            { optional
                                | olympicGamesParticipation = sc.olympicGamesParticipation |> GOA.fromMaybe
                                , worldCupParticipation = sc.worldCupParticipation |> GOA.fromMaybe
                                , trackRecord = sc.trackRecord |> GOA.fromMaybe
                                , bestMemory = sc.bestMemory |> GOA.fromMaybe
                                , decoration = sc.decoration |> GOA.fromMaybe
                            }
                        )
                        { id = Model.getId champion
                        , yearsInFrenchTeam = sc.yearsInFrenchTeam |> Dict.values |> List.map Model.getYear
                        }

                ProfessionalCareerBlock ->
                    let
                        pc =
                            champion.professionalCareer |> Editable.value
                    in
                    Mutation.updateChampionProfessionalCareer
                        (\optional ->
                            { optional
                                | background = pc.background |> GOA.fromMaybe
                                , volunteering = pc.volunteering |> GOA.fromMaybe
                            }
                        )
                        { id = Model.getId champion
                        , proExperiences = pc.proExperiences |> Dict.values |> List.map proExperienceToParams
                        }

                PicturesBlock ->
                    let
                        pictures =
                            champion.pictures |> Editable.value
                    in
                    Mutation.updateChampionPictures
                        { id = Model.getId champion
                        , pictures = pictures |> Dict.values |> List.map pictureToParams
                        }

                MedalsBlock ->
                    let
                        medals =
                            champion.medals |> Editable.value
                    in
                    Mutation.updateChampionMedals
                        { id = Model.getId champion
                        , medals = medals |> Dict.values |> List.map medalToParams
                        }
    in
    mutation
        (championSelection True)
        |> Graphql.Http.mutationRequest endpoint
        |> Graphql.Http.withCredentials
        |> Graphql.Http.send (RemoteData.fromResult >> GotSaveChampionResponse (Just block))


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
