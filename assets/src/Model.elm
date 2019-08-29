module Model exposing (Champion, ChampionPageModel, Champions, Flags, FormField(..), ListPageModel, Model, Msg(..), Page(..), Route(..), Sport(..), getId, initChampion, sportFromString, sportToString, sportsList)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Graphql.Http
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)


type alias Model =
    { currentPage : Page
    , key : Nav.Key
    , isAdmin : Bool
    }


type Page
    = ListPage ListPageModel
    | ChampionPage ChampionPageModel
    | NewChampionPage Champion


type alias ListPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    }


type alias ChampionPageModel =
    { id : Id
    , champion : RemoteData (Graphql.Http.Error Champion) Champion
    }


type Route
    = ListRoute
    | ChampionRoute Id
    | NewChampionRoute


type alias Champions =
    List Champion


type alias Champion =
    { id : Id
    , lastName : String
    , firstName : String
    , email : String
    , sport : Sport
    , proExperiences : List ProExperience
    }


type Sport
    = SkiAlpin
    | SkiDeFond
    | Biathlon
    | Combine
    | Freestyle
    | Saut
    | Snowboard


type alias ProExperience =
    { occupationalCategory : String
    , title : String
    , companyName : String
    , description : String
    , website : String
    , contact : String
    }


sportsList : List Sport
sportsList =
    [ SkiAlpin
    , SkiDeFond
    , Biathlon
    , Combine
    , Freestyle
    , Saut
    , Snowboard
    ]


getId : Champion -> String
getId { id } =
    case id of
        Id str ->
            str


type alias Flags =
    { isAdmin : Bool }


type Msg
    = NoOp
    | UrlRequested UrlRequest
    | UrlChanged Url
    | GotChampions (RemoteData (Graphql.Http.Error Champions) Champions)
    | GotChampion (RemoteData (Graphql.Http.Error Champion) Champion)
    | UpdatedChampionField FormField String
    | PressedSaveChampionButton
    | GotCreateChampionResponse (RemoteData (Graphql.Http.Error (Maybe Champion)) (Maybe Champion))
    | UpdatedChampionSport String
    | FilteredBySport String
    | PressedAddProExperienceButton


initChampion : Champion
initChampion =
    { id = Id "new"
    , lastName = ""
    , firstName = ""
    , email = ""
    , sport = SkiAlpin
    , proExperiences = []
    }


type FormField
    = FirstName
    | LastName
    | Email


sportToString : Sport -> String
sportToString sport =
    case sport of
        SkiAlpin ->
            "Ski alpin"

        SkiDeFond ->
            "Ski de fond"

        Biathlon ->
            "Biathlon"

        Combine ->
            "Combiné"

        Freestyle ->
            "Freestyle"

        Saut ->
            "Saut"

        Snowboard ->
            "Snowboard"


sportFromString : String -> Maybe Sport
sportFromString str =
    case str of
        "Ski alpin" ->
            Just SkiAlpin

        "Ski de fond" ->
            Just SkiDeFond

        "Biathlon" ->
            Just Biathlon

        "Combiné" ->
            Just Combine

        "Freestyle" ->
            Just Freestyle

        "Saut" ->
            Just Saut

        "Snowboard" ->
            Just Snowboard

        _ ->
            Nothing
