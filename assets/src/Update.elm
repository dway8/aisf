module Update exposing (getPageAndCmdFromRoute, parseUrl, update)

import Aisf.Scalar exposing (Id(..))
import Api
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Editable exposing (Editable(..))
import Graphql.Http
import Model exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)


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

        GotChampions resp ->
            ( { model | currentPage = ListPage { champions = resp, sport = Nothing } }, Cmd.none )

        GotChampion resp ->
            case ( model.currentPage, resp ) of
                ( ChampionPage { id }, Success champion ) ->
                    if id == champion.id then
                        ( { model | currentPage = ChampionPage { id = id, champion = resp } }
                        , Cmd.none
                        )

                    else
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        UpdatedChampionField field val ->
            updateNewChampion field val model

        PressedSaveChampionButton ->
            case model.currentPage of
                NewChampionPage { champion } ->
                    champion
                        |> validateChampionForm
                        |> Maybe.map (\champ -> ( model, Api.createChampion champ ))
                        |> Maybe.withDefault
                            (let
                                _ =
                                    Debug.log "errors" champion
                             in
                             ( model, Cmd.none )
                            )

                _ ->
                    ( model, Cmd.none )

        GotCreateChampionResponse resp ->
            handleCreateChampionResponse resp model

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


handleUrlChange : Url -> Model -> ( Model, Cmd Msg )
handleUrlChange newLocation model =
    let
        ( page, cmd ) =
            parseUrl newLocation
                |> getPageAndCmdFromRoute
    in
    ( { model | currentPage = page }, cmd )


parseUrl : Url -> Route
parseUrl url =
    url
        |> parse
            (oneOf
                [ map ListRoute top
                , map ListRoute (s "champions")
                , map NewChampionRoute (s "champions" </> s "new")
                , map (\intId -> ChampionRoute <| Id (String.fromInt intId)) (s "champions" </> int)
                ]
            )
        |> Maybe.withDefault ListRoute


getPageAndCmdFromRoute : Route -> ( Page, Cmd Msg )
getPageAndCmdFromRoute route =
    case route of
        ListRoute ->
            ( ListPage (ListPageModel Loading Nothing), Api.getChampions )

        ChampionRoute id ->
            ( ChampionPage (ChampionPageModel id Loading), Api.getChampion id )

        NewChampionRoute ->
            ( NewChampionPage { champion = Model.initChampionForm }, Cmd.none )


updateNewChampion : FormField -> String -> Model -> ( Model, Cmd Msg )
updateNewChampion field val model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newChamp =
                    case field of
                        FirstName ->
                            { champion | firstName = val }

                        LastName ->
                            { champion | lastName = val }

                        Email ->
                            { champion | email = val }

                        _ ->
                            champion
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChamp } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


handleCreateChampionResponse : RemoteData (Graphql.Http.Error (Maybe Champion)) (Maybe Champion) -> Model -> ( Model, Cmd Msg )
handleCreateChampionResponse response model =
    case response of
        Success _ ->
            ( model, Nav.pushUrl model.key "/" )

        _ ->
            ( model, Cmd.none )


updateCurrentSport : String -> Model -> ( Model, Cmd Msg )
updateCurrentSport sportStr model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newChamp =
                    { champion | sport = Model.sportFromString sportStr }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChamp } }, Cmd.none )

        ListPage lModel ->
            ( { model
                | currentPage =
                    ListPage
                        { lModel | sport = Model.sportFromString sportStr }
              }
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


addProExperience : Model -> ( Model, Cmd Msg )
addProExperience model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newKey =
                    getDictNextKey champion.proExperiences

                newProExperiences =
                    champion.proExperiences
                        |> Dict.map (\_ v -> Editable.save v)
                        |> Dict.insert newKey (ReadOnly Model.initProExperience |> Editable.edit)

                newChampion =
                    { champion | proExperiences = newProExperiences }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteProExperience : Int -> Model -> ( Model, Cmd Msg )
deleteProExperience id model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newProExperiences =
                    champion.proExperiences |> Dict.remove id

                newChampion =
                    { champion | proExperiences = newProExperiences }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateProExperience : Int -> FormField -> String -> Model -> ( Model, Cmd Msg )
updateProExperience id field val model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newProExperiences =
                    champion.proExperiences
                        |> Dict.update id
                            (Maybe.map
                                (Editable.map
                                    (\proExperience ->
                                        case field of
                                            OccupationalCategory ->
                                                { proExperience | occupationalCategory = val }

                                            Title ->
                                                { proExperience | title = val }

                                            CompanyName ->
                                                { proExperience | companyName = val }

                                            Description ->
                                                { proExperience | description = val }

                                            Website ->
                                                { proExperience | website = val }

                                            Contact ->
                                                { proExperience | contact = val }

                                            _ ->
                                                proExperience
                                    )
                                )
                            )

                newChampion =
                    { champion | proExperiences = newProExperiences }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


addYearInFrenchTeam : Model -> ( Model, Cmd Msg )
addYearInFrenchTeam model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
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
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateYearInFrenchTeam : Int -> String -> Model -> ( Model, Cmd Msg )
updateYearInFrenchTeam id str model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
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
                    ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


addMedal : Model -> ( Model, Cmd Msg )
addMedal model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newKey =
                    getDictNextKey champion.yearsInFrenchTeam

                newMedals =
                    champion.medals
                        |> Dict.map (\_ v -> Editable.save v)
                        |> Dict.insert newKey (ReadOnly (Model.initMedal model.currentYear) |> Editable.edit)

                newChampion =
                    { champion | medals = newMedals }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteMedal : Int -> Model -> ( Model, Cmd Msg )
deleteMedal id model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newMedals =
                    champion.medals |> Dict.remove id

                newChampion =
                    { champion | medals = newMedals }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalCompetition : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalCompetition id str model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            case Model.competitionFromString str of
                Just competition ->
                    let
                        newMedals =
                            champion.medals
                                |> Dict.update id (Maybe.map (Editable.map (\medal -> { medal | competition = competition })))

                        newChampion =
                            { champion | medals = newMedals }
                    in
                    ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateMedalYear : Int -> String -> Model -> ( Model, Cmd Msg )
updateMedalYear id str model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            case String.toInt str of
                Just year ->
                    let
                        newMedals =
                            champion.medals
                                |> Dict.update id (Maybe.map (Editable.map (\medal -> { medal | year = Year year })))

                        newChampion =
                            { champion | medals = newMedals }
                    in
                    ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

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
                { id = Id "NEW"
                , email = c.email
                , firstName = c.firstName
                , lastName = c.lastName
                , sport = sport
                , proExperiences = c.proExperiences |> Dict.values |> List.map Editable.value
                , yearsInFrenchTeam = c.yearsInFrenchTeam |> Dict.values |> List.map Editable.value
                , medals = c.medals |> Dict.values |> List.map Editable.value
                }
