module Model exposing (Champion, ChampionPageModel, Champions, Flags, FormField(..), ListPageModel, Model, Msg(..), NewChampionPageModel, Page(..), ProExperience, Route(..), Sport(..), getId, initChampion, initProExperience, sportFromString, sportToString, sportsList)

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
    | NewChampionPage NewChampionPageModel


type alias ListPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    }


type alias ChampionPageModel =
    { id : Id
    , champion : RemoteData (Graphql.Http.Error Champion) Champion
    }


type alias NewChampionPageModel =
    { champion : Champion
    , showYearSelector : Bool
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
    , yearsInFrenchTeam : List Int
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
    | SelectedASport String
    | PressedAddProExperienceButton
    | PressedDeleteProExperienceButton ProExperience
    | UpdatedProExperienceField ProExperience FormField String
    | PressedAddYearInFrenchTeamButton
    | SelectedAYear String


initChampion : Champion
initChampion =
    { id = Id "new"
    , lastName = ""
    , firstName = ""
    , email = ""
    , sport = SkiAlpin
    , proExperiences = []
    , yearsInFrenchTeam = []
    }


type FormField
    = FirstName
    | LastName
    | Email
    | OccupationalCategory
    | Title
    | CompanyName
    | Description
    | Website
    | Contact


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


initProExperience : ProExperience
initProExperience =
    { occupationalCategory = ""
    , title = ""
    , companyName = ""
    , description = ""
    , website = ""
    , contact = ""
    }
