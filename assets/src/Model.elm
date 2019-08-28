module Model exposing (Champion, ChampionPageModel, Champions, Flags, FormField(..), ListPageModel, Model, Msg(..), Page(..), Route(..), Sport(..), getId, initChampion, sportToString)

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
    { champions : RemoteData (Graphql.Http.Error Champions) Champions }


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
    , sport : Maybe Sport
    }


type Sport
    = SkiAlpin
    | SkiDeFond
    | Biathlon
    | Combine
    | Freestyle
    | Saut
    | Snowboard


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


initChampion : Champion
initChampion =
    { id = Id "new"
    , lastName = ""
    , firstName = ""
    , email = ""
    , sport = Nothing
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

        _ ->
            "Autre"
