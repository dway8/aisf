module Update exposing (getPageAndCmdFromRoute, parseUrl, update)

import Aisf.Scalar exposing (Id(..))
import Api
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
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
                    ( model, Api.createChampion champion )

                _ ->
                    ( model, Cmd.none )

        GotCreateChampionResponse resp ->
            handleCreateChampionResponse resp model

        SelectedASport sportStr ->
            updateCurrentSport sportStr model

        PressedAddProExperienceButton ->
            addProExperience model

        PressedDeleteProExperienceButton proExperience ->
            deleteProExperience proExperience model

        UpdatedProExperienceField proExperience field val ->
            updateProExperience proExperience field val model

        PressedAddYearInFrenchTeamButton ->
            showYearSelector model

        SelectedAYear str ->
            addChampionYearInFrenchTeam str model


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
            ( NewChampionPage { champion = Model.initChampion, showYearSelector = False }, Cmd.none )


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
                    { champion | sport = Model.sportFromString sportStr |> Maybe.withDefault champion.sport }
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
                newProExperiences =
                    champion.proExperiences ++ [ Model.initProExperience ]

                newChampion =
                    { champion | proExperiences = newProExperiences }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


deleteProExperience : ProExperience -> Model -> ( Model, Cmd Msg )
deleteProExperience proExperience model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newProExperiences =
                    champion.proExperiences |> List.filter ((/=) proExperience)

                newChampion =
                    { champion | proExperiences = newProExperiences }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateProExperience : ProExperience -> FormField -> String -> Model -> ( Model, Cmd Msg )
updateProExperience proExperience field val model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            let
                newProExperiences =
                    champion.proExperiences
                        |> List.map
                            (\exp ->
                                if exp == proExperience then
                                    case field of
                                        OccupationalCategory ->
                                            { exp | occupationalCategory = val }

                                        Title ->
                                            { exp | title = val }

                                        CompanyName ->
                                            { exp | companyName = val }

                                        Description ->
                                            { exp | description = val }

                                        Website ->
                                            { exp | website = val }

                                        Contact ->
                                            { exp | contact = val }

                                        _ ->
                                            exp

                                else
                                    exp
                            )

                newChampion =
                    { champion | proExperiences = newProExperiences }
            in
            ( { model | currentPage = NewChampionPage { m | champion = newChampion } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


showYearSelector : Model -> ( Model, Cmd Msg )
showYearSelector model =
    case model.currentPage of
        NewChampionPage m ->
            ( { model | currentPage = NewChampionPage { m | showYearSelector = True } }, Cmd.none )

        _ ->
            ( model, Cmd.none )


addChampionYearInFrenchTeam : String -> Model -> ( Model, Cmd Msg )
addChampionYearInFrenchTeam str model =
    case model.currentPage of
        NewChampionPage ({ champion } as m) ->
            case String.toInt str of
                Just year ->
                    ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
