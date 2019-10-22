module Update exposing (getPageAndCmdFromRoute, update)

import Aisf.Scalar exposing (Id(..))
import Api
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Dropdown
import File exposing (File)
import File.Select as Select
import Graphql.Http
import List.Extra as LE
import Menu
import Model exposing (..)
import Page.Champion
import Page.Champions
import Page.EditChampion
import Page.Events
import Page.Medals
import Page.Records
import Page.Teams
import RemoteData as RD exposing (RemoteData(..), WebData)
import Route exposing (Route(..))
import Table
import Task
import Url exposing (Url)
import Utils


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChanged newLocation ->
            handleUrlChange newLocation model

        UrlRequested urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                External _ ->
                    ( model, Cmd.none )

        GoBack ->
            goBack model

        ChampionSelected id ->
            selectChampion id model

        GotChampions resp ->
            handleChampionsResponse resp model

        GotChampion resp ->
            handleChampionResponse resp model

        UpdatedChampionField field val ->
            updateChampionForm field val model

        PressedSaveChampionButton ->
            case model.currentPage of
                EditChampionPage eModel ->
                    eModel.champion
                        |> RD.map
                            (\champion ->
                                champion
                                    |> validateChampionForm
                                    |> Maybe.map
                                        (\champ ->
                                            ( model
                                            , if champ.id == Id "new" then
                                                Api.createChampion champ

                                              else
                                                Api.updateChampion champ
                                            )
                                        )
                                    |> Maybe.withDefault ( model, Cmd.none )
                            )
                        |> RD.withDefault ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        GotSaveChampionResponse resp ->
            handleSaveChampionResponse resp model

        SelectedASport sportStr ->
            updateCurrentSport sportStr model

        PressedAddProExperienceButton ->
            addProExperience model

        PressedDeleteProExperienceButton id ->
            deleteProExperience id model

        UpdatedProExperienceField id field val ->
            updateProExperience id field val model

        PressedAddYearInFrenchTeamButton ->
            addYearInFrenchTeam model

        PressedDeleteYearInFrenchTeamButton id ->
            deleteYearInFrenchTeam id model

        PressedAddMedalButton ->
            addMedal model

        PressedDeleteMedalButton id ->
            deleteMedal id model

        SelectedAMedalCompetition id str ->
            updateMedalCompetition id str model

        SelectedAMedalYear id str ->
            updateMedalYear id str model

        SelectedAMedalSpecialty id str ->
            updateMedalSpecialty id str model

        SelectedASpecialty str ->
            updateCurrentSpecialty str model

        TableMsg tableState ->
            handleTableMsg tableState model

        SelectedAYear str ->
            updateCurrentYear str model

        BeganProfilePictureSelection ->
            beginFileSelection ProfilePictureSelectionDone model

        CancelledFileSelection ->
            cancelFileSelection model

        ProfilePictureSelectionDone file ->
            handleFileSelectionDone True file model

        PictureSelectionDone file ->
            handleFileSelectionDone False file model

        GotProfilePictureFileUrl base64file ->
            handleProfilePictureFileUrlReceived base64file model

        GotPictureFileUrl id base64file ->
            handlePictureFileUrlReceived id base64file model

        UpdatedSearchQuery query ->
            updateSearchQuery query model

        ResetSectorDropdown ->
            resetSectorDropdown model

        GotSectors resp ->
            handleSectorsResponse resp model

        SelectedASector name ->
            updateCurrentSector name model

        DropdownStateChanged menuMsg ->
            changeDropdownState menuMsg model

        UpdatedDropdownQuery str ->
            updateDropdownQuery str model

        DropdownGotFocus ->
            focusDropdown model

        DropdownLostFocus ->
            closeDropdown model

        ClosedDropdown ->
            closeDropdown model

        RemovedItemFromDropdown str ->
            removeItemFromDropdown str model

        CreatedASectorFromQuery ->
            createASectorFromQuery model

        PressedAddHighlightButton ->
            addHighlight model

        PressedDeleteHighlightButton id ->
            deleteHighlight id model

        UpdatedHighlight id str ->
            updateHighlight id str model

        PressedEditChampionButton id ->
            editChampion id model

        PressedAddPictureButton ->
            beginFileSelection PictureSelectionDone model

        PressedDeletePictureButton id ->
            deletePicture id model

        ClickedOnPicture id ->
            displayLargePicture id model

        ClickedOnPictureDialogBackground ->
            closePictureDialog model

        RequestedNextPicture direction ->
            showNextPicture direction model

        GotEvents resp ->
            handleEventsResponse resp model

        PressedAddEventButton ->
            addEvent model

        SelectedACompetition str ->
            updateCurrentCompetition str model

        CancelledNewEvent ->
            cancelNewEvent model

        UpdatedNewEventPlace str ->
            updateNewEventPlace str model

        SaveNewEvent ->
            saveNewEvent model

        GotSaveEventResponse resp ->
            handleSaveEventResponse resp model

        GotRecords resp ->
            handleRecordsResponse resp model

        PressedAddRecordButton ->
            addRecord model

        CancelledNewRecord ->
            cancelNewRecord model

        UpdatedNewRecordPlace str ->
            updateNewRecordPlace str model

        SaveNewRecord ->
            saveNewRecord model

        GotSaveRecordResponse resp ->
            handleSaveRecordResponse resp model

        SelectedARecordType str ->
            updateNewRecordType str model

        UpdatedRecordWinnerLastName index str ->
            updateRecordWinnerLastName index str model

        UpdatedRecordWinnerFirstName index str ->
            updateRecordWinnerFirstName index str model

        SelectedAMedalType index str ->
            updateMedalType index str model

        CheckedIsMember bool ->
            updateIsMember bool model


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange newLocation model =
    let
        ( page, cmd ) =
            Route.parseUrl newLocation
                |> getPageAndCmdFromRoute model.currentYear model.isAdmin model.key
    in
    ( { model | currentPage = page }, cmd )


goBack : Model -> ( Model, Cmd Msg )
goBack model =
    ( model, Nav.back model.key 1 )


getPageAndCmdFromRoute : Year -> Bool -> Nav.Key -> Route -> ( Page, Cmd Msg )
getPageAndCmdFromRoute currentYear isAdmin key route =
    case route of
        ChampionsRoute ->
            Page.Champions.init
                |> Tuple.mapFirst ChampionsPage

        MedalsRoute ->
            Page.Medals.init currentYear
                |> Tuple.mapFirst MedalsPage

        TeamsRoute ->
            Page.Teams.init currentYear
                |> Tuple.mapFirst TeamsPage

        ChampionRoute id ->
            Page.Champion.init isAdmin id
                |> Tuple.mapFirst ChampionPage

        EditChampionRoute maybeId ->
            Page.EditChampion.init maybeId
                |> Tuple.mapFirst EditChampionPage

        EventsRoute ->
            Page.Events.init currentYear
                |> Tuple.mapFirst EventsPage

        RecordsRoute ->
            Page.Records.init currentYear
                |> Tuple.mapFirst RecordsPage


updateChampionForm : FormField -> String -> Model -> ( Model, Cmd Msg )
updateChampionForm field val model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChamp =
                                case field of
                                    FirstName ->
                                        { champion | firstName = val }

                                    LastName ->
                                        { champion | lastName = val }

                                    Intro ->
                                        { champion | intro = Just val }

                                    FrenchTeamParticipation ->
                                        { champion | frenchTeamParticipation = Just val }

                                    OlympicGamesParticipation ->
                                        { champion | olympicGamesParticipation = Just val }

                                    WorldCupParticipation ->
                                        { champion | worldCupParticipation = Just val }

                                    TrackRecord ->
                                        { champion | trackRecord = Just val }

                                    BestMemory ->
                                        { champion | bestMemory = Just val }

                                    Decoration ->
                                        { champion | decoration = Just val }

                                    Background ->
                                        { champion | background = Just val }

                                    Volunteering ->
                                        { champion | volunteering = Just val }

                                    BirthDate ->
                                        { champion | birthDate = Just val }

                                    Email ->
                                        { champion | email = Just val }

                                    Address ->
                                        { champion | address = Just val }

                                    PhoneNumber ->
                                        { champion | phoneNumber = Just val }

                                    _ ->
                                        champion
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChamp } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleSaveChampionResponse : RemoteData (Graphql.Http.Error (Maybe Champion)) (Maybe Champion) -> Model -> ( Model, Cmd Msg )
handleSaveChampionResponse response model =
    case response of
        Success (Just { id }) ->
            ( model, Nav.pushUrl model.key (Route.routeToString (ChampionRoute id)) )

        _ ->
            ( model, Cmd.none )


updateCurrentSport : String -> Model -> ( Model, Cmd Msg )
updateCurrentSport sportStr model =
    let
        updateFn m =
            { m | sport = Model.sportFromString sportStr }
    in
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChamp =
                                { champion | sport = Model.sportFromString sportStr |> Maybe.withDefault champion.sport }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChamp } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        ChampionsPage cModel ->
            ( { model | currentPage = ChampionsPage (updateFn cModel) }
            , Cmd.none
            )

        MedalsPage mModel ->
            ( { model | currentPage = MedalsPage (updateFn mModel) }
            , Cmd.none
            )

        TeamsPage tModel ->
            ( { model | currentPage = TeamsPage (updateFn tModel) }
            , Cmd.none
            )

        EventsPage eModel ->
            case eModel.newEvent of
                Just event ->
                    let
                        newEvent =
                            { event | sport = Model.sportFromString sportStr }
                    in
                    ( { model | currentPage = EventsPage { eModel | newEvent = Just newEvent } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


addProExperience : Model -> ( Model, Cmd Msg )
addProExperience model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newKey =
                                getDictNextKey champion.proExperiences

                            newProExperiences =
                                champion.proExperiences
                                    |> Dict.insert newKey Model.initProExperience

                            newChampion =
                                { champion | proExperiences = newProExperiences }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteProExperience : Int -> Model -> ( Model, Cmd Msg )
deleteProExperience id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion | proExperiences = champion.proExperiences |> Dict.remove id }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateProExperience : Int -> FormField -> String -> Model -> ( Model, Cmd Msg )
updateProExperience id field val model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newProExperiences =
                                champion.proExperiences
                                    |> Dict.update id
                                        (Maybe.map
                                            (\proExperience ->
                                                case field of
                                                    Title ->
                                                        { proExperience | title = Just val }

                                                    CompanyName ->
                                                        { proExperience | companyName = Just val }

                                                    Description ->
                                                        { proExperience | description = Just val }

                                                    Website ->
                                                        { proExperience | website = Just val }

                                                    Contact ->
                                                        { proExperience | contact = Just val }

                                                    _ ->
                                                        proExperience
                                            )
                                        )

                            newChampion =
                                { champion | proExperiences = newProExperiences }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


addYearInFrenchTeam : Model -> ( Model, Cmd Msg )
addYearInFrenchTeam model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newKey =
                                getDictNextKey champion.yearsInFrenchTeam

                            newYears =
                                champion.yearsInFrenchTeam
                                    |> Dict.insert newKey model.currentYear

                            newChampion =
                                { champion | yearsInFrenchTeam = newYears }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteYearInFrenchTeam : Int -> Model -> ( Model, Cmd Msg )
deleteYearInFrenchTeam id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newYears =
                                champion.yearsInFrenchTeam
                                    |> Dict.remove id

                            newChampion =
                                { champion | yearsInFrenchTeam = newYears }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


addMedal : Model -> ( Model, Cmd Msg )
addMedal model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newKey =
                                getDictNextKey champion.medals

                            newMedals =
                                champion.medals
                                    |> Dict.insert newKey (Model.initMedal champion.sport model.currentYear)

                            newChampion =
                                { champion | medals = newMedals }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteMedal : Int -> Model -> ( Model, Cmd Msg )
deleteMedal id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newMedals =
                                champion.medals |> Dict.remove id

                            newChampion =
                                { champion | medals = newMedals }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalCompetition : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalCompetition id str model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        case Model.competitionFromString str of
                            Just competition ->
                                let
                                    newMedals =
                                        champion.medals
                                            |> Dict.update id (Maybe.map (\medal -> { medal | competition = competition }))

                                    newChampion =
                                        { champion | medals = newMedals }
                                in
                                ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalYear : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalYear id str model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        case String.toInt str of
                            Just year ->
                                let
                                    newMedals =
                                        champion.medals
                                            |> Dict.update id (Maybe.map (\medal -> { medal | year = Year year }))

                                    newChampion =
                                        { champion | medals = newMedals }
                                in
                                ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalSpecialty : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalSpecialty id str model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        case Model.specialtyFromString str of
                            Just specialty ->
                                let
                                    newMedals =
                                        champion.medals
                                            |> Dict.update id (Maybe.map (\medal -> { medal | specialty = specialty }))

                                    newChampion =
                                        { champion | medals = newMedals }
                                in
                                ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


getDictNextKey : Dict Int a -> Int
getDictNextKey =
    Dict.keys
        >> List.sort
        >> List.reverse
        >> List.head
        >> Maybe.map ((+) 1)
        >> Maybe.withDefault 0


validateChampionForm : ChampionForm -> Maybe Champion
validateChampionForm c =
    --TODO validation
    Just
        { id = c.id
        , email = c.email
        , firstName = c.firstName
        , lastName = c.lastName
        , birthDate = c.birthDate
        , address = c.address
        , phoneNumber = c.phoneNumber
        , website = c.website
        , sport = c.sport
        , proExperiences = c.proExperiences |> Dict.values
        , yearsInFrenchTeam = c.yearsInFrenchTeam |> Dict.values
        , medals = c.medals |> Dict.values
        , isMember = c.isMember
        , intro = c.intro
        , highlights = c.highlights |> Dict.values
        , profilePicture = c.profilePicture
        , frenchTeamParticipation = c.frenchTeamParticipation
        , olympicGamesParticipation = c.olympicGamesParticipation
        , worldCupParticipation = c.worldCupParticipation
        , trackRecord = c.trackRecord
        , bestMemory = c.bestMemory
        , decoration = c.decoration
        , background = c.background
        , volunteering = c.volunteering
        , oldId = Nothing
        , pictures = c.pictures |> Dict.values
        }


updateCurrentSpecialty : String -> Model -> ( Model, Cmd Msg )
updateCurrentSpecialty str model =
    case model.currentPage of
        MedalsPage mModel ->
            ( { model
                | currentPage =
                    MedalsPage
                        { mModel | specialty = Model.specialtyFromString str }
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


updateCurrentYear : String -> Model -> ( Model, Cmd Msg )
updateCurrentYear str model =
    let
        updateFn m =
            { m | selectedYear = str |> String.toInt |> Maybe.map Year }
    in
    case model.currentPage of
        MedalsPage mModel ->
            ( { model | currentPage = MedalsPage (updateFn mModel) }
            , Cmd.none
            )

        TeamsPage tModel ->
            ( { model | currentPage = TeamsPage (updateFn tModel) }
            , Cmd.none
            )

        EventsPage eModel ->
            case ( eModel.newEvent, String.toInt str ) of
                ( Just event, Just year ) ->
                    let
                        newEvent =
                            { event | year = Year year }
                    in
                    ( { model | currentPage = EventsPage { eModel | newEvent = Just newEvent } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleChampionsResponse : RemoteData (Graphql.Http.Error Champions) Champions -> Model -> ( Model, Cmd Msg )
handleChampionsResponse resp model =
    case model.currentPage of
        ChampionsPage cModel ->
            ( { model | currentPage = ChampionsPage { cModel | champions = resp, sport = Nothing } }, Cmd.none )

        MedalsPage mModel ->
            ( { model | currentPage = MedalsPage { mModel | champions = resp } }, Cmd.none )

        TeamsPage tModel ->
            ( { model | currentPage = TeamsPage { tModel | champions = resp } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleTableMsg : Table.State -> Model -> ( Model, Cmd msg )
handleTableMsg tableState model =
    let
        updateFn m =
            { m | tableState = tableState }

        newPage =
            case model.currentPage of
                ChampionsPage cModel ->
                    ChampionsPage (updateFn cModel)

                MedalsPage mModel ->
                    MedalsPage (updateFn mModel)

                TeamsPage tModel ->
                    TeamsPage (updateFn tModel)

                ChampionPage cModel ->
                    ChampionPage { cModel | medalsTableState = tableState }

                EventsPage eModel ->
                    EventsPage (updateFn eModel)

                _ ->
                    model.currentPage
    in
    ( { model | currentPage = newPage }, Cmd.none )


selectChampion : Id -> Model -> ( Model, Cmd Msg )
selectChampion id model =
    ( model, Nav.pushUrl model.key (Route.routeToString <| ChampionRoute id) )


handleChampionResponse : RemoteData (Graphql.Http.Error Champion) Champion -> Model -> ( Model, Cmd Msg )
handleChampionResponse resp model =
    case ( model.currentPage, resp ) of
        ( ChampionPage cModel, Success champion ) ->
            if cModel.id == champion.id then
                ( { model | currentPage = ChampionPage { cModel | champion = resp } }
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        ( EditChampionPage { id }, Success champion ) ->
            if id == Just champion.id then
                ( { model
                    | currentPage =
                        EditChampionPage
                            { id = id
                            , champion = Success (Page.EditChampion.championToForm champion)
                            , sectorDropdown = Dropdown.init
                            , medalsTableState = Table.initialSort "ANNÉE"
                            }
                  }
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


beginFileSelection : (File -> Msg) -> Model -> ( Model, Cmd Msg )
beginFileSelection doneMsg model =
    ( model, Select.file [ "image/*" ] doneMsg )


cancelFileSelection : Model -> ( Model, Cmd Msg )
cancelFileSelection model =
    ( model, Cmd.none )


handleFileSelectionDone : Bool -> File -> Model -> ( Model, Cmd Msg )
handleFileSelectionDone isProfilePicture file model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            ( newChampion, gotFileUrlMsg ) =
                                if isProfilePicture then
                                    ( { champion | profilePicture = Just <| Attachment (File.name file) Nothing }
                                    , GotProfilePictureFileUrl
                                    )

                                else
                                    let
                                        newKey =
                                            getDictNextKey champion.highlights

                                        newPictures =
                                            champion.pictures
                                                |> Dict.insert newKey (Model.initPicture (File.name file))
                                    in
                                    ( { champion | pictures = newPictures }, GotPictureFileUrl newKey )
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }
                        , Task.perform gotFileUrlMsg <| File.toUrl file
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleProfilePictureFileUrlReceived : String -> Model -> ( Model, Cmd Msg )
handleProfilePictureFileUrlReceived base64file model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                case champion.profilePicture of
                                    Nothing ->
                                        champion

                                    Just oldFile ->
                                        let
                                            newFile =
                                                { oldFile | base64 = Just base64file }
                                        in
                                        { champion | profilePicture = Just newFile }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }
                        , Cmd.none
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handlePictureFileUrlReceived : Int -> String -> Model -> ( Model, Cmd Msg )
handlePictureFileUrlReceived id base64file model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newPictures =
                                champion.pictures
                                    |> Dict.update id
                                        (Maybe.map
                                            (\({ attachment } as pic) ->
                                                { pic | attachment = { attachment | base64 = Just base64file } }
                                            )
                                        )

                            newChampion =
                                { champion | pictures = newPictures }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }
                        , Cmd.none
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateSearchQuery : String -> Model -> ( Model, Cmd Msg )
updateSearchQuery query model =
    case model.currentPage of
        ChampionsPage cModel ->
            ( { model | currentPage = ChampionsPage { cModel | searchQuery = Just query } }, Cmd.none )

        TeamsPage tModel ->
            ( { model | currentPage = TeamsPage { tModel | searchQuery = Just query } }, Cmd.none )

        MedalsPage medModel ->
            ( { model | currentPage = MedalsPage { medModel | searchQuery = Just query } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleSectorsResponse : RemoteData (Graphql.Http.Error Sectors) Sectors -> Model -> ( Model, Cmd Msg )
handleSectorsResponse resp model =
    ( { model | sectors = resp }, Cmd.none )


updateCurrentSector : String -> Model -> ( Model, Cmd Msg )
updateCurrentSector name model =
    case ( model.currentPage, model.isAdmin, model.sectors ) of
        ( ChampionsPage cModel, True, Success sectors ) ->
            ( { model | currentPage = ChampionsPage { cModel | sector = Model.findSectorByName sectors name } }
            , Cmd.none
            )

        ( EditChampionPage eModel, True, _ ) ->
            ( { model | currentPage = EditChampionPage (updateChampionWithProExperienceSector name eModel) }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateChampionWithProExperienceSector : String -> EditChampionPageModel -> EditChampionPageModel
updateChampionWithProExperienceSector sectorName eModel =
    case eModel.champion of
        Success champion ->
            let
                newChampion =
                    { champion
                        | proExperiences =
                            champion.proExperiences
                                |> Dict.map (\id exp -> { exp | sectors = exp.sectors ++ [ sectorName ] })
                    }
            in
            { eModel
                | champion = Success newChampion
                , sectorDropdown = eModel.sectorDropdown |> Dropdown.toggleMenu False |> Dropdown.addSelected sectorName |> Dropdown.setQuery Nothing
            }

        _ ->
            eModel


changeDropdownState : Menu.Msg -> Model -> ( Model, Cmd Msg )
changeDropdownState menuMsg model =
    case ( model.currentPage, model.sectors ) of
        ( EditChampionPage eModel, Success sectors ) ->
            let
                dropdown =
                    eModel.sectorDropdown

                acceptableSectors =
                    Model.acceptableSectors dropdown.query sectors

                ( newState, maybeMsg ) =
                    Menu.update (Dropdown.updateConfig SelectedASector CreatedASectorFromQuery ResetSectorDropdown)
                        menuMsg
                        20
                        dropdown.state
                        acceptableSectors

                newDropdown =
                    Dropdown.setState newState eModel.sectorDropdown
                        |> (if acceptableSectors == [] then
                                Dropdown.emptyState

                            else
                                identity
                           )

                newEModel =
                    { eModel | sectorDropdown = newDropdown }

                newModel =
                    { model | currentPage = EditChampionPage newEModel }
            in
            maybeMsg
                |> Maybe.map (\updateMsg -> update updateMsg newModel)
                |> Maybe.withDefault ( newModel, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateDropdownQuery : String -> Model -> ( Model, Cmd Msg )
updateDropdownQuery newQuery model =
    case model.currentPage of
        EditChampionPage eModel ->
            let
                newModel =
                    { eModel
                        | sectorDropdown =
                            eModel.sectorDropdown
                                |> Dropdown.setQuery (Just newQuery)
                                |> Dropdown.toggleMenu (newQuery /= "")
                    }
            in
            ( { model | currentPage = EditChampionPage newModel }, Cmd.none )

        _ ->
            ( model, Cmd.none )


focusDropdown : Model -> ( Model, Cmd Msg )
focusDropdown model =
    case model.currentPage of
        EditChampionPage eModel ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


closeDropdown : Model -> ( Model, Cmd Msg )
closeDropdown model =
    case model.currentPage of
        EditChampionPage eModel ->
            let
                newModel =
                    { eModel
                        | sectorDropdown =
                            eModel.sectorDropdown
                                |> Dropdown.toggleMenu False
                                |> Dropdown.setQuery Nothing
                    }
            in
            ( { model | currentPage = EditChampionPage newModel }, Cmd.none )

        _ ->
            ( model, Cmd.none )


removeItemFromDropdown : String -> Model -> ( Model, Cmd Msg )
removeItemFromDropdown str model =
    case model.currentPage of
        EditChampionPage eModel ->
            let
                newModel =
                    { eModel
                        | sectorDropdown =
                            eModel.sectorDropdown
                                |> Dropdown.removeSelected str
                    }
            in
            ( { model | currentPage = EditChampionPage newModel }, Cmd.none )

        _ ->
            ( model, Cmd.none )


createASectorFromQuery : Model -> ( Model, Cmd Msg )
createASectorFromQuery model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.sectorDropdown.query
                |> Maybe.map
                    (\query ->
                        let
                            capitalizedQuery =
                                Utils.capitalize query

                            newEModel =
                                updateChampionWithProExperienceSector capitalizedQuery eModel

                            newSectors =
                                model.sectors
                                    |> RD.map (\sectors -> sectors ++ [ Model.createSector capitalizedQuery ])
                        in
                        ( { model | currentPage = EditChampionPage newEModel, sectors = newSectors }, Cmd.none )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


resetSectorDropdown : Model -> ( Model, Cmd Msg )
resetSectorDropdown model =
    case model.currentPage of
        EditChampionPage ({ sectorDropdown } as eModel) ->
            let
                newSectorDropdown =
                    sectorDropdown |> Dropdown.emptyState
            in
            ( { model | currentPage = EditChampionPage { eModel | sectorDropdown = newSectorDropdown } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


addHighlight : Model -> ( Model, Cmd Msg )
addHighlight model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newKey =
                                getDictNextKey champion.highlights

                            newHighlights =
                                champion.highlights
                                    |> Dict.insert newKey ""

                            newChampion =
                                { champion | highlights = newHighlights }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteHighlight : Int -> Model -> ( Model, Cmd Msg )
deleteHighlight id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion | highlights = champion.highlights |> Dict.remove id }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateHighlight : Int -> String -> Model -> ( Model, Cmd Msg )
updateHighlight id val model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newHighlights =
                                champion.highlights
                                    |> Dict.update id (Maybe.map (always val))

                            newChampion =
                                { champion | highlights = newHighlights }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


editChampion : Id -> Model -> ( Model, Cmd Msg )
editChampion id model =
    if model.isAdmin then
        ( model, Nav.pushUrl model.key (Route.routeToString <| EditChampionRoute (Just id)) )

    else
        ( model, Cmd.none )


deletePicture : Int -> Model -> ( Model, Cmd Msg )
deletePicture id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion | pictures = champion.pictures |> Dict.remove id }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


displayLargePicture : Int -> Model -> ( Model, Cmd Msg )
displayLargePicture idx model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            pictureToDisplay =
                                LE.getAt idx champion.pictures
                        in
                        ( { model | currentPage = ChampionPage { cModel | pictureDialog = pictureToDisplay } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


closePictureDialog : Model -> ( Model, Cmd Msg )
closePictureDialog model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        ( { model | currentPage = ChampionPage { cModel | pictureDialog = Nothing } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


showNextPicture : Int -> Model -> ( Model, Cmd Msg )
showNextPicture direction model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            nextPicture =
                                cModel.pictureDialog
                                    |> Maybe.andThen (\p -> LE.elemIndex p champion.pictures)
                                    |> Maybe.map ((+) direction)
                                    |> Maybe.andThen (\newIndex -> LE.getAt newIndex champion.pictures)
                                    |> (\maybePic ->
                                            case maybePic of
                                                Just pic ->
                                                    Just pic

                                                Nothing ->
                                                    cModel.pictureDialog
                                       )
                        in
                        ( { model | currentPage = ChampionPage { cModel | pictureDialog = nextPicture } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleEventsResponse : RemoteData (Graphql.Http.Error Events) Events -> Model -> ( Model, Cmd Msg )
handleEventsResponse resp model =
    case model.currentPage of
        EventsPage eModel ->
            ( { model | currentPage = EventsPage { eModel | events = resp } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


addEvent : Model -> ( Model, Cmd Msg )
addEvent model =
    case model.currentPage of
        EventsPage eModel ->
            ( { model | currentPage = EventsPage { eModel | newEvent = Just <| Model.initEvent model.currentYear } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateCurrentCompetition : String -> Model -> ( Model, Cmd Msg )
updateCurrentCompetition str model =
    case model.currentPage of
        EventsPage eModel ->
            case ( eModel.newEvent, Model.competitionFromString str ) of
                ( Just event, Just competition ) ->
                    let
                        newSport =
                            if competition == OlympicGames then
                                Nothing

                            else
                                event.sport

                        newEvent =
                            { event | competition = competition, sport = newSport }
                    in
                    ( { model | currentPage = EventsPage { eModel | newEvent = Just newEvent } }, Cmd.none )

                ( Nothing, _ ) ->
                    ( { model | currentPage = EventsPage { eModel | competition = Model.competitionFromString str } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


cancelNewEvent : Model -> ( Model, Cmd Msg )
cancelNewEvent model =
    case model.currentPage of
        EventsPage eModel ->
            ( { model | currentPage = EventsPage { eModel | newEvent = Nothing } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateNewEventPlace : String -> Model -> ( Model, Cmd Msg )
updateNewEventPlace str model =
    case model.currentPage of
        EventsPage eModel ->
            case eModel.newEvent of
                Just event ->
                    let
                        newEvent =
                            { event | place = str }
                    in
                    ( { model | currentPage = EventsPage { eModel | newEvent = Just newEvent } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


saveNewEvent : Model -> ( Model, Cmd Msg )
saveNewEvent model =
    case model.currentPage of
        EventsPage eModel ->
            case eModel.newEvent of
                Just event ->
                    ( { model | currentPage = EventsPage { eModel | newEvent = Nothing } }, Api.createEvent event )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleSaveEventResponse : RemoteData (Graphql.Http.Error Event) Event -> Model -> ( Model, Cmd Msg )
handleSaveEventResponse response model =
    case ( model.currentPage, response ) of
        ( EventsPage eModel, Success event ) ->
            eModel.events
                |> RD.map
                    (\events ->
                        ( { model | currentPage = EventsPage { eModel | events = Success (event :: events) } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleRecordsResponse : RemoteData (Graphql.Http.Error Records) Records -> Model -> ( Model, Cmd Msg )
handleRecordsResponse resp model =
    case model.currentPage of
        RecordsPage rModel ->
            ( { model | currentPage = RecordsPage { rModel | records = resp } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


addRecord : Model -> ( Model, Cmd Msg )
addRecord model =
    case model.currentPage of
        RecordsPage rModel ->
            ( { model | currentPage = RecordsPage { rModel | newRecord = Just <| Model.initRecord model.currentYear } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


cancelNewRecord : Model -> ( Model, Cmd Msg )
cancelNewRecord model =
    case model.currentPage of
        RecordsPage rModel ->
            ( { model | currentPage = RecordsPage { rModel | newRecord = Nothing } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateNewRecordPlace : String -> Model -> ( Model, Cmd Msg )
updateNewRecordPlace str model =
    case model.currentPage of
        RecordsPage rModel ->
            case rModel.newRecord of
                Just record ->
                    let
                        newRecord =
                            { record | place = str }
                    in
                    ( { model | currentPage = RecordsPage { rModel | newRecord = Just newRecord } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


saveNewRecord : Model -> ( Model, Cmd Msg )
saveNewRecord model =
    case model.currentPage of
        RecordsPage rModel ->
            case rModel.newRecord of
                Just record ->
                    if
                        record.winners
                            |> Dict.values
                            |> List.any (\w -> String.isEmpty w.lastName || String.isEmpty w.firstName)
                    then
                        ( model, Cmd.none )

                    else
                        ( { model | currentPage = RecordsPage { rModel | newRecord = Nothing } }, Api.createRecord record )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleSaveRecordResponse : RemoteData (Graphql.Http.Error Record) Record -> Model -> ( Model, Cmd Msg )
handleSaveRecordResponse response model =
    case ( model.currentPage, response ) of
        ( RecordsPage rModel, Success record ) ->
            rModel.records
                |> RD.map
                    (\records ->
                        ( { model | currentPage = RecordsPage { rModel | records = Success (record :: records) } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateNewRecordType : String -> Model -> ( Model, Cmd Msg )
updateNewRecordType str model =
    case model.currentPage of
        RecordsPage rModel ->
            case ( rModel.newRecord, str |> String.toInt ) of
                ( Just record, Just recordTypeInt ) ->
                    case Model.recordTypeFromInt recordTypeInt of
                        Just recordType ->
                            let
                                newWinners =
                                    List.range 1 recordTypeInt
                                        |> List.foldl
                                            (\i acc ->
                                                Dict.get i record.winners
                                                    |> Maybe.withDefault (Winner "" "")
                                                    |> (\w -> Dict.insert i w acc)
                                            )
                                            Dict.empty

                                newRecord =
                                    { record | recordType = recordType, winners = newWinners }
                            in
                            ( { model | currentPage = RecordsPage { rModel | newRecord = Just newRecord } }, Cmd.none )

                        Nothing ->
                            ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateRecordWinnerLastName : Int -> String -> Model -> ( Model, Cmd Msg )
updateRecordWinnerLastName index str model =
    updateRecordWinnerNameField index str (\winner -> Winner str winner.firstName) model


updateRecordWinnerFirstName : Int -> String -> Model -> ( Model, Cmd Msg )
updateRecordWinnerFirstName index str model =
    updateRecordWinnerNameField index str (\winner -> Winner winner.lastName str) model


updateRecordWinnerNameField : Int -> String -> (Winner -> Winner) -> Model -> ( Model, Cmd Msg )
updateRecordWinnerNameField index str updateFn model =
    case model.currentPage of
        RecordsPage rModel ->
            case rModel.newRecord of
                Just record ->
                    let
                        newWinners =
                            record.winners
                                |> Dict.update index (Maybe.map updateFn)

                        newRecord =
                            { record | winners = newWinners }
                    in
                    ( { model | currentPage = RecordsPage { rModel | newRecord = Just newRecord } }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalType : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalType id str model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        case str |> String.toInt |> Maybe.andThen Model.medalTypeFromInt of
                            Just medalType ->
                                let
                                    newMedals =
                                        champion.medals
                                            |> Dict.update id (Maybe.map (\medal -> { medal | medalType = medalType }))

                                    newChampion =
                                        { champion | medals = newMedals }
                                in
                                ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateIsMember : Bool -> Model -> ( Model, Cmd Msg )
updateIsMember bool model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion | isMember = bool }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
