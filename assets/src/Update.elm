module Update exposing (getPageAndCmdFromRoute, update)

import Aisf.Scalar exposing (Id(..))
import Api
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Dropdown
import Editable exposing (Editable(..))
import File exposing (File)
import File.Select as Select
import Graphql.Http
import Menu
import Model exposing (..)
import Page.Admin
import Page.Champion
import Page.EditChampion
import Page.Medals
import Page.Members
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

        SelectedAYearInFrenchTeam id str ->
            updateYearInFrenchTeam id str model

        PressedAddMedalButton ->
            addMedal model

        PressedDeleteMedalButton id ->
            deleteMedal id model

        SelectedACompetition id str ->
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

        PressedEditProExperienceButton id ->
            editProExperience id model

        PressedEditMedalButton id ->
            editMedal id model

        BeganFileSelection ->
            beginFileSelection model

        CancelledFileSelection ->
            cancelFileSelection model

        FileSelectionDone file ->
            handleFileSelectionDone file model

        GotFileUrl base64file ->
            handleFileUrlReceived base64file model

        UpdatedSearchQuery query ->
            updateSearchQuery query model

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

        PressedEditHighlightButton id ->
            editHighlight id model

        PressedDeleteHighlightButton id ->
            deleteHighlight id model

        CancelledHighlightEdition id ->
            cancelHighlightEdition id model

        UpdatedHighlight id str ->
            updateHighlight id str model

        PressedConfirmHighlightButton id ->
            confirmHighlight id model

        PressedEditChampionButton id ->
            editChampion id model


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
        MembersRoute ->
            Page.Members.init
                |> Tuple.mapFirst MembersPage

        MedalsRoute ->
            Page.Medals.init currentYear
                |> Tuple.mapFirst MedalsPage

        TeamsRoute ->
            Page.Teams.init currentYear
                |> Tuple.mapFirst TeamsPage

        ChampionRoute id ->
            Page.Champion.init id
                |> Tuple.mapFirst ChampionPage

        EditChampionRoute maybeId ->
            Page.EditChampion.init maybeId
                |> Tuple.mapFirst EditChampionPage

        AdminRoute ->
            if isAdmin then
                Page.Admin.init
                    |> Tuple.mapFirst AdminPage

            else
                Page.Members.init
                    |> Tuple.mapBoth MembersPage (\cmds -> Nav.pushUrl key "/")


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

                                    Email ->
                                        { champion | email = Just val }

                                    Intro ->
                                        { champion | intro = Just val }

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
                                updateFn champion
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChamp } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        MembersPage memModel ->
            ( { model | currentPage = MembersPage (updateFn memModel) }
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

        AdminPage aModel ->
            ( { model | currentPage = AdminPage (updateFn aModel) }
            , Cmd.none
            )

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
                                    |> Dict.insert newKey (ReadOnly Model.initProExperience |> Editable.edit)

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
                                            (Editable.map
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
                                    |> Dict.map (\_ v -> Editable.save v)
                                    |> Dict.insert newKey (ReadOnly model.currentYear |> Editable.edit)

                            newChampion =
                                { champion | yearsInFrenchTeam = newYears }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateYearInFrenchTeam : Int -> String -> Model -> ( Model, Cmd Msg )
updateYearInFrenchTeam id str model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        case String.toInt str of
                            Just year ->
                                let
                                    newYears =
                                        champion.yearsInFrenchTeam
                                            |> Dict.update id (Maybe.map (Editable.map (\y -> Year year)))
                                            |> Dict.map (\_ v -> Editable.save v)

                                    newChampion =
                                        { champion | yearsInFrenchTeam = newYears }
                                in
                                ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
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
                                case champion.sport of
                                    Just sport ->
                                        champion.medals
                                            |> Dict.insert newKey (ReadOnly (Model.initMedal sport model.currentYear) |> Editable.edit)

                                    Nothing ->
                                        champion.medals

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
                                            |> Dict.update id (Maybe.map (Editable.map (\medal -> { medal | competition = competition })))

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
                                            |> Dict.update id (Maybe.map (Editable.map (\medal -> { medal | year = Year year })))

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
                                            |> Dict.update id (Maybe.map (Editable.map (\medal -> { medal | specialty = specialty })))

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
    case c.sport of
        Nothing ->
            Nothing

        Just sport ->
            Just
                { id = c.id
                , email = c.email
                , firstName = c.firstName
                , lastName = c.lastName
                , birthDate = c.birthDate
                , address = c.address
                , phoneNumber = c.phoneNumber
                , website = c.website
                , sport = sport
                , proExperiences = c.proExperiences |> Dict.values |> List.map Editable.value
                , yearsInFrenchTeam = c.yearsInFrenchTeam |> Dict.values |> List.map Editable.value
                , medals = c.medals |> Dict.values |> List.map Editable.value
                , isMember = c.isMember
                , intro = c.intro
                , highlights = c.highlights |> Dict.values |> List.map Editable.value
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

        _ ->
            ( model, Cmd.none )


handleChampionsResponse : RemoteData (Graphql.Http.Error Champions) Champions -> Model -> ( Model, Cmd Msg )
handleChampionsResponse resp model =
    case model.currentPage of
        MembersPage memModel ->
            ( { model | currentPage = MembersPage { memModel | champions = resp, sport = Nothing } }, Cmd.none )

        MedalsPage mModel ->
            ( { model | currentPage = MedalsPage { mModel | champions = resp } }, Cmd.none )

        TeamsPage tModel ->
            ( { model | currentPage = TeamsPage { tModel | champions = resp } }, Cmd.none )

        AdminPage aModel ->
            ( { model | currentPage = AdminPage { aModel | champions = resp } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleTableMsg : Table.State -> Model -> ( Model, Cmd msg )
handleTableMsg tableState model =
    let
        updateFn m =
            { m | tableState = tableState }

        newPage =
            case model.currentPage of
                MembersPage memModel ->
                    MembersPage (updateFn memModel)

                MedalsPage mModel ->
                    MedalsPage (updateFn mModel)

                TeamsPage tModel ->
                    TeamsPage (updateFn tModel)

                AdminPage aModel ->
                    AdminPage (updateFn aModel)

                _ ->
                    model.currentPage
    in
    ( { model | currentPage = newPage }, Cmd.none )


selectChampion : Id -> Model -> ( Model, Cmd Msg )
selectChampion (Id id) model =
    ( model, Nav.pushUrl model.key ("/champions/" ++ id) )


handleChampionResponse : RemoteData (Graphql.Http.Error Champion) Champion -> Model -> ( Model, Cmd Msg )
handleChampionResponse resp model =
    case ( model.currentPage, resp ) of
        ( ChampionPage { id }, Success champion ) ->
            if id == champion.id then
                ( { model | currentPage = ChampionPage { id = id, champion = resp } }
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
                            }
                  }
                , Cmd.none
                )

            else
                ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


editProExperience : Int -> Model -> ( Model, Cmd Msg )
editProExperience id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            experienceToEdit =
                                Dict.get id champion.proExperiences

                            newProExp =
                                champion.proExperiences
                                    |> Dict.map (\_ exp -> Editable.cancel exp)
                                    |> Dict.update id (Maybe.map Editable.edit)

                            newChampion =
                                { champion | proExperiences = newProExp }

                            newDropdown =
                                experienceToEdit
                                    |> Maybe.map Editable.value
                                    |> Maybe.map (\exp -> Dropdown.setSelected exp.sectors eModel.sectorDropdown)
                                    |> Maybe.withDefault eModel.sectorDropdown
                        in
                        ( { model
                            | currentPage =
                                EditChampionPage
                                    { eModel
                                        | champion = Success newChampion
                                        , sectorDropdown = newDropdown
                                    }
                          }
                        , Cmd.none
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


editMedal : Int -> Model -> ( Model, Cmd Msg )
editMedal id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newMedals =
                                champion.medals
                                    |> Dict.update id (Maybe.map Editable.edit)

                            newChampion =
                                { champion | medals = newMedals }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


beginFileSelection : Model -> ( Model, Cmd Msg )
beginFileSelection model =
    ( model, Select.file [ "image/*" ] FileSelectionDone )


cancelFileSelection : Model -> ( Model, Cmd Msg )
cancelFileSelection model =
    ( model, Cmd.none )


handleFileSelectionDone : File -> Model -> ( Model, Cmd Msg )
handleFileSelectionDone file model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newChampion =
                                { champion | profilePicture = Just <| Attachment (File.name file) Nothing }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }
                        , Task.perform GotFileUrl <| File.toUrl file
                        )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleFileUrlReceived : String -> Model -> ( Model, Cmd Msg )
handleFileUrlReceived base64file model =
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


updateSearchQuery : String -> Model -> ( Model, Cmd Msg )
updateSearchQuery query model =
    case model.currentPage of
        AdminPage aModel ->
            ( { model | currentPage = AdminPage { aModel | searchQuery = Just query } }, Cmd.none )

        MembersPage mModel ->
            ( { model | currentPage = MembersPage { mModel | searchQuery = Just query } }, Cmd.none )

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
    case ( model.currentPage, model.sectors ) of
        ( AdminPage aModel, Success sectors ) ->
            ( { model | currentPage = AdminPage { aModel | sector = Model.findSectorByName sectors name } }
            , Cmd.none
            )

        ( EditChampionPage eModel, _ ) ->
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
                                |> Dict.map
                                    (\id exp ->
                                        exp
                                            |> Editable.map (\editingExp -> { editingExp | sectors = editingExp.sectors ++ [ sectorName ] })
                                    )
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

                ( newState, maybeMsg ) =
                    Menu.update (Dropdown.updateConfig SelectedASector CreatedASectorFromQuery)
                        menuMsg
                        20
                        dropdown.state
                        (Model.acceptableSectors dropdown.query sectors)

                newEModel =
                    { eModel | sectorDropdown = Dropdown.setState newState eModel.sectorDropdown }

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
                                |> Dropdown.removeSelected
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
                                case champion.sport of
                                    Just sport ->
                                        champion.highlights
                                            |> Dict.insert newKey (ReadOnly "" |> Editable.edit)

                                    Nothing ->
                                        champion.highlights

                            newChampion =
                                { champion | highlights = newHighlights }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


editHighlight : Int -> Model -> ( Model, Cmd Msg )
editHighlight id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            highlightToEdit =
                                Dict.get id champion.highlights

                            newHighlights =
                                champion.highlights
                                    |> Dict.map (\_ exp -> Editable.cancel exp)
                                    |> Dict.update id (Maybe.map Editable.edit)

                            newChampion =
                                { champion | highlights = newHighlights }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }
                        , Cmd.none
                        )
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


cancelHighlightEdition : Int -> Model -> ( Model, Cmd Msg )
cancelHighlightEdition id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newHighlights =
                                champion.highlights
                                    |> Dict.update id
                                        (Maybe.andThen
                                            (\highlight ->
                                                case highlight of
                                                    ReadOnly _ ->
                                                        Just highlight

                                                    Editable old new ->
                                                        case new of
                                                            "" ->
                                                                Nothing

                                                            _ ->
                                                                Just <| ReadOnly old
                                            )
                                        )

                            newChampion =
                                { champion | highlights = newHighlights }
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
                                    |> Dict.update id
                                        (Maybe.map (Editable.map (always val)))

                            newChampion =
                                { champion | highlights = newHighlights }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


confirmHighlight : Int -> Model -> ( Model, Cmd Msg )
confirmHighlight id model =
    case model.currentPage of
        EditChampionPage eModel ->
            eModel.champion
                |> RD.map
                    (\champion ->
                        let
                            newHighlights =
                                champion.highlights
                                    |> Dict.update id (Maybe.map Editable.save)

                            newChampion =
                                { champion | highlights = newHighlights }
                        in
                        ( { model | currentPage = EditChampionPage { eModel | champion = Success newChampion } }, Cmd.none )
                    )
                |> RD.withDefault ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


editChampion : Id -> Model -> ( Model, Cmd Msg )
editChampion (Id id) model =
    if model.isAdmin then
        ( model, Nav.pushUrl model.key ("/champions/edit/" ++ id) )

    else
        ( model, Cmd.none )
