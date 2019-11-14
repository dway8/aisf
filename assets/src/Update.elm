module Update exposing (getPageAndCmdFromRoute, update)

import Aisf.Scalar exposing (Id(..))
import Api
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Dropdown
import Editable
import File exposing (File)
import File.Select as Select
import Graphql.Http
import List.Extra as LE
import Menu
import Model exposing (..)
import Page.Champion
import Page.Champions
import Page.Events
import Page.Login
import Page.Medals
import Page.NewChampion
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

        RequestedPreviousListingPage ->
            goToPreviousListing model

        ChampionSelected id ->
            selectChampion id model

        GotChampions resp ->
            handleChampionsResponse resp model

        GotChampion resp ->
            handleChampionResponse resp model

        UpdatedChampionField block field val ->
            updateChampionForm block field val model

        PressedSaveChampionButton block ->
            saveChampion block model

        GotSaveChampionResponse maybeBlock resp ->
            handleSaveChampionResponse maybeBlock resp model

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

        SelectedAYearInFrenchTeam id str ->
            updateYearInFrenchTeam id str model

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

        UpdatedLoginNameField str ->
            updateLoginNameField str model

        UpdatedLoginIdField str ->
            updateLoginIdField str model

        PressedLoginButton ->
            login model

        GotLoginResponse resp ->
            handleLoginResponse resp model

        PressedEditBlockButton block ->
            editFormBlock block model

        PressedCancelEditionButton block ->
            cancelEdition block model

        PressedSaveNewChampionButton ->
            saveNewChampion model

        GotCreateChampionResponse resp ->
            handleCreateChampionResponse resp model


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange newLocation model =
    let
        ( newPage, cmd ) =
            Route.parseUrl newLocation
                |> getPageAndCmdFromRoute model.currentYear model.isAdmin model.championLoggedIn model.key

        previousListing =
            case model.currentPage of
                ChampionsPage _ ->
                    Just ChampionsRoute

                MedalsPage _ ->
                    Just MedalsRoute

                TeamsPage _ ->
                    Just TeamsRoute

                _ ->
                    model.previousListing
    in
    ( { model | currentPage = newPage, previousListing = previousListing }, cmd )


goToPreviousListing : Model -> ( Model, Cmd Msg )
goToPreviousListing model =
    let
        newRoute =
            model.previousListing
                |> Maybe.withDefault ChampionsRoute
    in
    ( model, Nav.pushUrl model.key (Route.routeToString newRoute) )


getPageAndCmdFromRoute : Year -> Bool -> Maybe Id -> Nav.Key -> Route -> ( Page, Cmd Msg )
getPageAndCmdFromRoute currentYear isAdmin championLoggedIn key route =
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
            Page.Champion.init currentYear isAdmin championLoggedIn id
                |> Tuple.mapFirst ChampionPage

        NewChampionRoute ->
            Page.NewChampion.init
                |> Tuple.mapFirst NewChampionPage

        EventsRoute ->
            Page.Events.init currentYear
                |> Tuple.mapFirst EventsPage

        RecordsRoute ->
            Page.Records.init currentYear
                |> Tuple.mapFirst RecordsPage

        LoginRoute ->
            Page.Login.init
                |> Tuple.mapFirst LoginPage


updateChampionForm : FormBlock -> FormField -> String -> Model -> ( Model, Cmd Msg )
updateChampionForm block field val model =
    let
        applyChangesOnChampion c =
            case block of
                PresentationBlock ->
                    { c
                        | presentation =
                            c.presentation
                                |> Editable.map
                                    (\pres ->
                                        case field of
                                            FirstName ->
                                                { pres | firstName = val }

                                            LastName ->
                                                { pres | lastName = val }

                                            Intro ->
                                                { pres | intro = Just val }

                                            _ ->
                                                pres
                                    )
                    }

                PrivateInfoBlock ->
                    { c
                        | privateInfo =
                            c.privateInfo
                                |> Editable.map
                                    (\pi ->
                                        case field of
                                            BirthDate ->
                                                { pi | birthDate = Just val }

                                            Address ->
                                                { pi | address = Just val }

                                            Email ->
                                                { pi | email = Just val }

                                            PhoneNumber ->
                                                { pi | phoneNumber = Just val }

                                            _ ->
                                                pi
                                    )
                    }

                SportCareerBlock ->
                    { c
                        | sportCareer =
                            c.sportCareer
                                |> Editable.map
                                    (\sc ->
                                        case field of
                                            OlympicGamesParticipation ->
                                                { sc | olympicGamesParticipation = Just val }

                                            WorldCupParticipation ->
                                                { sc | worldCupParticipation = Just val }

                                            TrackRecord ->
                                                { sc | trackRecord = Just val }

                                            BestMemory ->
                                                { sc | bestMemory = Just val }

                                            Decoration ->
                                                { sc | decoration = Just val }

                                            _ ->
                                                sc
                                    )
                    }

                ProfessionalCareerBlock ->
                    { c
                        | professionalCareer =
                            c.professionalCareer
                                |> Editable.map
                                    (\pc ->
                                        case field of
                                            Background ->
                                                { pc | background = Just val }

                                            Volunteering ->
                                                { pc | volunteering = Just val }

                                            _ ->
                                                pc
                                    )
                    }

                _ ->
                    c
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map (\champion -> ( { model | currentPage = ChampionPage { cModel | champion = Success (applyChangesOnChampion champion) } }, Cmd.none ))
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = applyChangesOnChampion nModel.champion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleSaveChampionResponse : Maybe FormBlock -> RemoteData (Graphql.Http.Error (Maybe Champion)) (Maybe Champion) -> Model -> ( Model, Cmd Msg )
handleSaveChampionResponse maybeFormBlock response model =
    case ( model.currentPage, response ) of
        ( ChampionPage cModel, Success (Just receivedChampion) ) ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        maybeFormBlock
                            |> Maybe.map
                                (\block ->
                                    let
                                        newChampion =
                                            case block of
                                                PresentationBlock ->
                                                    { champion | presentation = champion.presentation |> Editable.save }

                                                PrivateInfoBlock ->
                                                    { champion | privateInfo = champion.privateInfo |> Editable.save }

                                                SportCareerBlock ->
                                                    { champion | sportCareer = champion.sportCareer |> Editable.save }

                                                ProfessionalCareerBlock ->
                                                    { champion | professionalCareer = champion.professionalCareer |> Editable.save }

                                                MedalsBlock ->
                                                    { champion | medals = champion.medals |> Editable.save }

                                                PicturesBlock ->
                                                    { champion | pictures = champion.pictures |> Editable.save }
                                    in
                                    ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                                )
                            |> Maybe.withDefault ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateCurrentSport : String -> Model -> ( Model, Cmd Msg )
updateCurrentSport sportStr model =
    let
        updateSportInChampion c =
            { c
                | presentation =
                    c.presentation
                        |> Editable.map (\pres -> { pres | sport = Model.sportFromString sportStr |> Maybe.withDefault pres.sport })
            }

        updateSportInModel m =
            { m | sport = Model.sportFromString sportStr }
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        ( { model | currentPage = ChampionPage { cModel | champion = Success (updateSportInChampion champion) } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = updateSportInChampion nModel.champion } }, Cmd.none )

        ChampionsPage cModel ->
            ( { model | currentPage = ChampionsPage (updateSportInModel cModel) }
            , Cmd.none
            )

        MedalsPage mModel ->
            ( { model | currentPage = MedalsPage (updateSportInModel mModel) }
            , Cmd.none
            )

        TeamsPage tModel ->
            ( { model | currentPage = TeamsPage (updateSportInModel tModel) }
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
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion
                                    | professionalCareer =
                                        champion.professionalCareer
                                            |> Editable.map
                                                (\pc ->
                                                    let
                                                        newKey =
                                                            getDictNextKey pc.proExperiences

                                                        newProExperiences =
                                                            pc.proExperiences
                                                                |> Dict.insert newKey Model.initProExperience
                                                    in
                                                    { pc | proExperiences = newProExperiences }
                                                )
                                }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteProExperience : Int -> Model -> ( Model, Cmd Msg )
deleteProExperience id model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion
                                    | professionalCareer =
                                        champion.professionalCareer
                                            |> Editable.map (\pc -> { pc | proExperiences = pc.proExperiences |> Dict.remove id })
                                }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateProExperience : Int -> FormField -> String -> Model -> ( Model, Cmd Msg )
updateProExperience id field val model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion
                                    | professionalCareer =
                                        champion.professionalCareer
                                            |> Editable.map
                                                (\pc ->
                                                    { pc
                                                        | proExperiences =
                                                            pc.proExperiences
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
                                                    }
                                                )
                                }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


addYearInFrenchTeam : Model -> ( Model, Cmd Msg )
addYearInFrenchTeam model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion
                                    | sportCareer =
                                        champion.sportCareer
                                            |> Editable.map
                                                (\sc ->
                                                    let
                                                        newKey =
                                                            getDictNextKey sc.yearsInFrenchTeam

                                                        newYears =
                                                            sc.yearsInFrenchTeam
                                                                |> Dict.insert newKey model.currentYear
                                                    in
                                                    { sc | yearsInFrenchTeam = newYears }
                                                )
                                }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateYearInFrenchTeam : Int -> String -> Model -> ( Model, Cmd Msg )
updateYearInFrenchTeam id str model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        case String.toInt str of
                            Just year ->
                                let
                                    newChampion =
                                        { champion
                                            | sportCareer =
                                                champion.sportCareer
                                                    |> Editable.map
                                                        (\sc ->
                                                            let
                                                                newYears =
                                                                    sc.yearsInFrenchTeam
                                                                        |> Dict.insert id (Year year)
                                                            in
                                                            { sc | yearsInFrenchTeam = newYears }
                                                        )
                                        }
                                in
                                ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteYearInFrenchTeam : Int -> Model -> ( Model, Cmd Msg )
deleteYearInFrenchTeam id model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion
                                    | sportCareer =
                                        champion.sportCareer
                                            |> Editable.map
                                                (\sc ->
                                                    let
                                                        newYears =
                                                            sc.yearsInFrenchTeam
                                                                |> Dict.remove id
                                                    in
                                                    { sc | yearsInFrenchTeam = newYears }
                                                )
                                }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


addMedal : Model -> ( Model, Cmd Msg )
addMedal model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion
                                    | medals =
                                        champion.medals
                                            |> Editable.map
                                                (\medals ->
                                                    let
                                                        newKey =
                                                            getDictNextKey medals

                                                        sport =
                                                            champion.presentation |> Editable.value |> .sport
                                                    in
                                                    medals
                                                        |> Dict.insert newKey (Model.initMedal sport model.currentYear)
                                                )
                                }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteMedal : Int -> Model -> ( Model, Cmd Msg )
deleteMedal id model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion | medals = champion.medals |> Editable.map (Dict.remove id) }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalCompetition : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalCompetition id str model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        case Model.competitionFromString str of
                            Just competition ->
                                let
                                    newChampion =
                                        { champion | medals = champion.medals |> Editable.map (Dict.update id (Maybe.map (\medal -> { medal | competition = competition }))) }
                                in
                                ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalYear : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalYear id str model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        case String.toInt str of
                            Just year ->
                                let
                                    newChampion =
                                        { champion | medals = champion.medals |> Editable.map (Dict.update id (Maybe.map (\medal -> { medal | year = Year year }))) }
                                in
                                ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalSpecialty : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalSpecialty id str model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        case Model.specialtyFromString str of
                            Just specialty ->
                                let
                                    newChampion =
                                        { champion | medals = champion.medals |> Editable.map (Dict.update id (Maybe.map (\medal -> { medal | specialty = specialty }))) }
                                in
                                ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )

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
    ( { model | champions = resp }, Cmd.none )


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
        ( ChampionPage { id }, Success champion ) ->
            if id == champion.id then
                ( { model
                    | currentPage =
                        ChampionPage
                            { id = id
                            , champion = Success champion
                            , sectorDropdown = Dropdown.init
                            , medalsTableState = Table.initialSort "ANNÉE"
                            , pictureDialog = Nothing
                            , currentYear = model.currentYear
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
    let
        doUpdateProfilePicOfChampion c =
            { c
                | presentation =
                    c.presentation
                        |> Editable.map (\p -> { p | profilePicture = Just <| Attachment (File.name file) Nothing })
            }
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            ( newChampion, gotFileUrlMsg ) =
                                if isProfilePicture then
                                    ( doUpdateProfilePicOfChampion champion
                                    , GotProfilePictureFileUrl
                                    )

                                else
                                    let
                                        newKey =
                                            getDictNextKey (Editable.value champion.pictures)

                                        newPictures =
                                            champion.pictures
                                                |> Editable.map (Dict.insert newKey (Model.initPicture (File.name file)))
                                    in
                                    ( { champion | pictures = newPictures }, GotPictureFileUrl newKey )
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }
                        , Task.perform gotFileUrlMsg <| File.toUrl file
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = doUpdateProfilePicOfChampion nModel.champion } }
            , Task.perform GotProfilePictureFileUrl <| File.toUrl file
            )

        _ ->
            ( model, Cmd.none )


handleProfilePictureFileUrlReceived : String -> Model -> ( Model, Cmd Msg )
handleProfilePictureFileUrlReceived base64file model =
    let
        updateProfilePicOfChampion c =
            { c
                | presentation =
                    c.presentation
                        |> Editable.map
                            (\p ->
                                case p.profilePicture of
                                    Nothing ->
                                        p

                                    Just oldFile ->
                                        let
                                            newFile =
                                                { oldFile | base64 = Just base64file }
                                        in
                                        { p | profilePicture = Just newFile }
                            )
            }
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        ( { model | currentPage = ChampionPage { cModel | champion = Success (updateProfilePicOfChampion champion) } }
                        , Cmd.none
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = updateProfilePicOfChampion nModel.champion } }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


handlePictureFileUrlReceived : Int -> String -> Model -> ( Model, Cmd Msg )
handlePictureFileUrlReceived id base64file model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion
                                    | pictures =
                                        champion.pictures
                                            |> Editable.map
                                                (Dict.update id
                                                    (Maybe.map
                                                        (\({ attachment } as pic) ->
                                                            { pic | attachment = { attachment | base64 = Just base64file } }
                                                        )
                                                    )
                                                )
                                }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }
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

        ( ChampionPage cModel, True, _ ) ->
            ( { model | currentPage = ChampionPage (updateChampionWithProExperienceSector name cModel) }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateChampionWithProExperienceSector : String -> ChampionPageModel -> ChampionPageModel
updateChampionWithProExperienceSector sectorName cModel =
    case cModel.champion of
        Success champion ->
            let
                newChampion =
                    { champion
                        | professionalCareer =
                            champion.professionalCareer
                                |> Editable.map
                                    (\pc ->
                                        { pc | proExperiences = pc.proExperiences |> Dict.map (\id exp -> { exp | sectors = exp.sectors ++ [ sectorName ] }) }
                                    )
                    }
            in
            { cModel
                | champion = Success newChampion
                , sectorDropdown = cModel.sectorDropdown |> Dropdown.toggleMenu False |> Dropdown.addSelected sectorName |> Dropdown.setQuery Nothing
            }

        _ ->
            cModel


changeDropdownState : Menu.Msg -> Model -> ( Model, Cmd Msg )
changeDropdownState menuMsg model =
    case ( model.currentPage, model.sectors ) of
        ( ChampionPage cModel, Success sectors ) ->
            let
                dropdown =
                    cModel.sectorDropdown

                acceptableSectors =
                    Model.acceptableSectors dropdown.query sectors

                ( newState, maybeMsg ) =
                    Menu.update (Dropdown.updateConfig SelectedASector CreatedASectorFromQuery ResetSectorDropdown)
                        menuMsg
                        20
                        dropdown.state
                        acceptableSectors

                newDropdown =
                    Dropdown.setState newState cModel.sectorDropdown
                        |> (if acceptableSectors == [] then
                                Dropdown.emptyState

                            else
                                identity
                           )

                newEModel =
                    { cModel | sectorDropdown = newDropdown }

                newModel =
                    { model | currentPage = ChampionPage newEModel }
            in
            maybeMsg
                |> Maybe.map (\updateMsg -> update updateMsg newModel)
                |> Maybe.withDefault ( newModel, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateDropdownQuery : String -> Model -> ( Model, Cmd Msg )
updateDropdownQuery newQuery model =
    case model.currentPage of
        ChampionPage cModel ->
            let
                newModel =
                    { cModel
                        | sectorDropdown =
                            cModel.sectorDropdown
                                |> Dropdown.setQuery (Just newQuery)
                                |> Dropdown.toggleMenu (newQuery /= "")
                    }
            in
            ( { model | currentPage = ChampionPage newModel }, Cmd.none )

        _ ->
            ( model, Cmd.none )


focusDropdown : Model -> ( Model, Cmd Msg )
focusDropdown model =
    case model.currentPage of
        ChampionPage cModel ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


closeDropdown : Model -> ( Model, Cmd Msg )
closeDropdown model =
    case model.currentPage of
        ChampionPage cModel ->
            let
                newModel =
                    { cModel
                        | sectorDropdown =
                            cModel.sectorDropdown
                                |> Dropdown.toggleMenu False
                                |> Dropdown.setQuery Nothing
                    }
            in
            ( { model | currentPage = ChampionPage newModel }, Cmd.none )

        _ ->
            ( model, Cmd.none )


removeItemFromDropdown : String -> Model -> ( Model, Cmd Msg )
removeItemFromDropdown str model =
    case model.currentPage of
        ChampionPage cModel ->
            let
                newModel =
                    { cModel
                        | sectorDropdown =
                            cModel.sectorDropdown
                                |> Dropdown.removeSelected str
                    }
            in
            ( { model | currentPage = ChampionPage newModel }, Cmd.none )

        _ ->
            ( model, Cmd.none )


createASectorFromQuery : Model -> ( Model, Cmd Msg )
createASectorFromQuery model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.sectorDropdown.query
                |> Maybe.map
                    (\query ->
                        let
                            capitalizedQuery =
                                Utils.capitalize query

                            newEModel =
                                updateChampionWithProExperienceSector capitalizedQuery cModel

                            newSectors =
                                model.sectors
                                    |> RD.map (\sectors -> sectors ++ [ Model.createSector capitalizedQuery ])
                        in
                        ( { model | currentPage = ChampionPage newEModel, sectors = newSectors }, Cmd.none )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


resetSectorDropdown : Model -> ( Model, Cmd Msg )
resetSectorDropdown model =
    case model.currentPage of
        ChampionPage ({ sectorDropdown } as cModel) ->
            let
                newSectorDropdown =
                    sectorDropdown |> Dropdown.emptyState
            in
            ( { model | currentPage = ChampionPage { cModel | sectorDropdown = newSectorDropdown } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


addHighlight : Model -> ( Model, Cmd Msg )
addHighlight model =
    let
        addHighlightToChampion c =
            { c
                | presentation =
                    c.presentation
                        |> Editable.map
                            (\p ->
                                let
                                    newKey =
                                        getDictNextKey p.highlights
                                in
                                { p | highlights = p.highlights |> Dict.insert newKey "" }
                            )
            }
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        ( { model | currentPage = ChampionPage { cModel | champion = Success (addHighlightToChampion champion) } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = addHighlightToChampion nModel.champion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteHighlight : Int -> Model -> ( Model, Cmd Msg )
deleteHighlight id model =
    let
        deleteHighlightFromChampion c =
            { c
                | presentation =
                    c.presentation |> Editable.map (\p -> { p | highlights = p.highlights |> Dict.remove id })
            }
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        ( { model | currentPage = ChampionPage { cModel | champion = Success (deleteHighlightFromChampion champion) } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = deleteHighlightFromChampion nModel.champion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateHighlight : Int -> String -> Model -> ( Model, Cmd Msg )
updateHighlight id val model =
    let
        updateHighlightInChampion c =
            { c
                | presentation =
                    c.presentation |> Editable.map (\p -> { p | highlights = p.highlights |> Dict.update id (Maybe.map (always val)) })
            }
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        ( { model | currentPage = ChampionPage { cModel | champion = Success (updateHighlightInChampion champion) } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = updateHighlightInChampion nModel.champion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


editChampion : Id -> Model -> ( Model, Cmd Msg )
editChampion id model =
    if model.isAdmin || (model.championLoggedIn == Just id) then
        ( model, Nav.pushUrl model.key (Route.routeToString <| ChampionRoute id) )

    else
        ( model, Cmd.none )


deletePicture : Int -> Model -> ( Model, Cmd Msg )
deletePicture id model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion | pictures = champion.pictures |> Editable.map (Dict.remove id) }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
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
                                Dict.get idx (champion.pictures |> Editable.value)
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
                            pictures =
                                champion.pictures |> Editable.value

                            nextPicture =
                                cModel.pictureDialog
                                    |> Maybe.andThen (\p -> pictures |> Dict.values |> LE.elemIndex p)
                                    |> Maybe.map ((+) direction)
                                    |> Maybe.andThen (\newIndex -> Dict.get newIndex pictures)
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
                    if String.isEmpty event.place then
                        ( model, Cmd.none )

                    else
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
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        case str |> String.toInt |> Maybe.andThen Model.medalTypeFromInt of
                            Just medalType ->
                                let
                                    newChampion =
                                        { champion | medals = champion.medals |> Editable.map (Dict.update id (Maybe.map (\medal -> { medal | medalType = medalType }))) }
                                in
                                ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateIsMember : Bool -> Model -> ( Model, Cmd Msg )
updateIsMember bool model =
    let
        doUpdate c =
            { c | presentation = c.presentation |> Editable.map (\p -> { p | isMember = bool }) }
    in
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map (\champion -> ( { model | currentPage = ChampionPage { cModel | champion = Success (doUpdate champion) } }, Cmd.none ))
                |> RD.withDefault ( model, Cmd.none )

        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | champion = doUpdate nModel.champion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateLoginNameField : String -> Model -> ( Model, Cmd Msg )
updateLoginNameField str model =
    case model.currentPage of
        LoginPage lModel ->
            ( { model | currentPage = LoginPage { lModel | lastName = str } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateLoginIdField : String -> Model -> ( Model, Cmd Msg )
updateLoginIdField str model =
    case model.currentPage of
        LoginPage lModel ->
            ( { model | currentPage = LoginPage { lModel | loginId = str } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


login : Model -> ( Model, Cmd Msg )
login model =
    case model.currentPage of
        LoginPage ({ lastName, loginId } as lModel) ->
            if List.any String.isEmpty [ lastName, loginId ] then
                ( model, Cmd.none )

            else
                ( { model | currentPage = LoginPage { lModel | loginRequest = Loading } }
                , Api.login lastName loginId
                )

        _ ->
            ( model, Cmd.none )


handleLoginResponse : RemoteData (Graphql.Http.Error LoginResponse) LoginResponse -> Model -> ( Model, Cmd Msg )
handleLoginResponse resp model =
    case model.currentPage of
        LoginPage lModel ->
            case resp of
                Success (Authorized id) ->
                    ( { model | championLoggedIn = Just id }, Nav.pushUrl model.key (Route.routeToString (ChampionRoute id)) )

                _ ->
                    ( { model | currentPage = LoginPage { lModel | loginRequest = resp } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


editFormBlock : FormBlock -> Model -> ( Model, Cmd Msg )
editFormBlock block model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                case block of
                                    PresentationBlock ->
                                        { champion | presentation = champion.presentation |> Editable.edit }

                                    PrivateInfoBlock ->
                                        { champion | privateInfo = champion.privateInfo |> Editable.edit }

                                    SportCareerBlock ->
                                        { champion | sportCareer = champion.sportCareer |> Editable.edit }

                                    ProfessionalCareerBlock ->
                                        { champion | professionalCareer = champion.professionalCareer |> Editable.edit }

                                    MedalsBlock ->
                                        { champion | medals = champion.medals |> Editable.edit }

                                    PicturesBlock ->
                                        { champion | pictures = champion.pictures |> Editable.edit }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


saveChampion : FormBlock -> Model -> ( Model, Cmd Msg )
saveChampion block model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        ( model
                        , if model.isAdmin || (model.championLoggedIn == Just champion.id) then
                            Api.updateChampion block champion

                          else
                            Cmd.none
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


cancelEdition : FormBlock -> Model -> ( Model, Cmd Msg )
cancelEdition block model =
    case model.currentPage of
        ChampionPage cModel ->
            cModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                case block of
                                    PresentationBlock ->
                                        { champion | presentation = champion.presentation |> Editable.cancel }

                                    PrivateInfoBlock ->
                                        { champion | privateInfo = champion.privateInfo |> Editable.cancel }

                                    SportCareerBlock ->
                                        { champion | sportCareer = champion.sportCareer |> Editable.cancel }

                                    ProfessionalCareerBlock ->
                                        { champion | professionalCareer = champion.professionalCareer |> Editable.cancel }

                                    MedalsBlock ->
                                        { champion | medals = champion.medals |> Editable.cancel }

                                    PicturesBlock ->
                                        { champion | pictures = champion.pictures |> Editable.cancel }
                        in
                        ( { model | currentPage = ChampionPage { cModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


saveNewChampion : Model -> ( Model, Cmd Msg )
saveNewChampion model =
    case model.currentPage of
        NewChampionPage nModel ->
            ( { model | currentPage = NewChampionPage { nModel | saveRequest = Loading } }
            , if model.isAdmin then
                nModel.champion |> Api.createChampion

              else
                Cmd.none
            )

        _ ->
            ( model, Cmd.none )


handleCreateChampionResponse : RemoteData (Graphql.Http.Error (Maybe Champion)) (Maybe Champion) -> Model -> ( Model, Cmd Msg )
handleCreateChampionResponse response model =
    case ( model.currentPage, response ) of
        ( NewChampionPage cModel, Success (Just receivedChampion) ) ->
            ( { model
                | champions =
                    model.champions
                        |> RD.map (\list -> (receivedChampion |> Page.Champion.toChampionLite) :: list)
              }
            , Nav.pushUrl model.key (Route.routeToString <| ChampionRoute receivedChampion.id)
            )

        _ ->
            ( model, Cmd.none )
