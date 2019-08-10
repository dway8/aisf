module Model exposing (Champion, Champions, Flags, FormField(..), Model, Msg(..), Page(..), Route(..), getId, initChampion)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Graphql.Http
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)


type alias Model =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , currentPage : Page
    , key : Nav.Key
    , isAdmin : Bool
    }


type Page
    = ListPage
    | ChampionPage Id (RemoteData (Graphql.Http.Error Champion) Champion)
    | NewChampionPage Champion


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
    }


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


initChampion : Champion
initChampion =
    { id = Id "new"
    , lastName = ""
    , firstName = ""
    , email = ""
    }


type FormField
    = FirstName
    | LastName
    | Email
