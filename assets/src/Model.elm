module Model exposing (Champion, ChampionPageModel, Champions, Competition(..), Flags, FormField(..), ListPageModel, Medal, MedalType(..), Model, Msg(..), NewChampionPageModel, Page(..), ProExperience, Route(..), Specialty(..), Sport(..), competitionFromString, getId, initChampion, initProExperience, medalTypeFromInt, specialtyFromString, sportFromString, sportToString, sportsList)

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
    , medals : List Medal
    }


type alias Medal =
    { competition : Competition
    , year : Int
    , specialty : Specialty
    , medalType : MedalType
    }


type Competition
    = OlympicGames
    | WorldChampionships
    | WorldCup


competitionFromString : String -> Maybe Competition
competitionFromString str =
    case str of
        "OlympicGames" ->
            Just OlympicGames

        "WorldChampionships" ->
            Just WorldChampionships

        "WorldCup" ->
            Just WorldCup

        _ ->
            Nothing


medalTypeFromInt : Int -> Maybe MedalType
medalTypeFromInt int =
    case int of
        1 ->
            Just Gold

        2 ->
            Just Silver

        3 ->
            Just Bronze

        _ ->
            Nothing


specialtyFromString : String -> Maybe Specialty
specialtyFromString str =
    case str of
        "Slalom" ->
            Just Slalom

        "SlalomGeneral" ->
            Just SlalomGeneral

        "Descente" ->
            Just Descente

        "DescenteGeneral" ->
            Just DescenteGeneral

        "SuperG" ->
            Just SuperG

        "SuperGGeneral" ->
            Just SuperGGeneral

        "SuperCombine" ->
            Just SuperCombine

        "SuperCombineGeneral" ->
            Just SuperCombineGeneral

        "Geant" ->
            Just Geant

        "General" ->
            Just General

        "Combine" ->
            Just Combine

        "ParEquipe" ->
            Just ParEquipe

        "Individuel" ->
            Just Individuel

        "IndividuelGeneral" ->
            Just IndividuelGeneral

        "Sprint" ->
            Just Sprint

        "SprintGeneral" ->
            Just SprintGeneral

        "Poursuite" ->
            Just Poursuite

        "PoursuiteGeneral" ->
            Just PoursuiteGeneral

        "Relais" ->
            Just Relais

        "RelaisGeneral" ->
            Just RelaisGeneral

        "SprintX2" ->
            Just SprintX2

        "SprintX2General" ->
            Just SprintX2General

        "MassStart" ->
            Just MassStart

        "ParEquipeGeneral" ->
            Just ParEquipeGeneral

        "Bosses" ->
            Just Bosses

        "BossesGeneral" ->
            Just BossesGeneral

        "SautBigAir" ->
            Just SautBigAir

        "SautBigAirGeneral" ->
            Just SautBigAirGeneral

        "SkiCross" ->
            Just SkiCross

        "SkiCrossGeneral" ->
            Just SkiCrossGeneral

        "HalfPipe" ->
            Just HalfPipe

        "HalfPipeGeneral" ->
            Just HalfPipeGeneral

        "Slopestyle" ->
            Just Slopestyle

        "Acrobatique" ->
            Just Acrobatique

        "Artistique" ->
            Just Artistique

        "SautSpecial" ->
            Just SautSpecial

        "SautSpecialGeneral" ->
            Just SautSpecialGeneral

        "VolASki" ->
            Just VolASki

        "VolASkiGeneral" ->
            Just VolASkiGeneral

        "Cross" ->
            Just Cross

        "CrossGeneral" ->
            Just CrossGeneral

        "SnowFreestyle" ->
            Just SnowFreestyle

        "SnowFreestyleGeneral" ->
            Just SnowFreestyleGeneral

        "SnowAlpin" ->
            Just SnowAlpin

        "SnowAlpinGeneral" ->
            Just SnowAlpinGeneral

        _ ->
            Nothing


type Specialty
    = -- Alpin
      Slalom
    | SlalomGeneral
    | Descente
    | DescenteGeneral
    | SuperG
    | SuperGGeneral
    | SuperCombine
    | SuperCombineGeneral
    | Geant
    | General
    | Combine
    | ParEquipe
      -- Fond
    | Individuel
    | IndividuelGeneral
    | Sprint
    | SprintGeneral
    | Poursuite
    | PoursuiteGeneral
    | Relais
    | RelaisGeneral
    | SprintX2
    | SprintX2General
      -- Biathlon
    | MassStart
      -- CombineNordique
    | ParEquipeGeneral
      -- Freestyle
    | Bosses
    | BossesGeneral
    | SautBigAir
    | SautBigAirGeneral
    | SkiCross
    | SkiCrossGeneral
    | HalfPipe
    | HalfPipeGeneral
    | Slopestyle
    | Acrobatique
    | Artistique
      -- Saut
    | SautSpecial
    | SautSpecialGeneral
    | VolASki
    | VolASkiGeneral
      -- Snowboard
    | Cross
    | CrossGeneral
    | SnowFreestyle
    | SnowFreestyleGeneral
    | SnowAlpin
    | SnowAlpinGeneral



-- ALPIN 1
-- slalom + cl général
-- descente + cl général
-- super G + cl général
-- super combiné + cl général
-- géant
-- cl général
-- combiné
-- par équipe
--
-- FOND 2
-- individuel + cl général
-- sprint + cl général
-- poursuite + cl général
-- relais + cl général
-- sprint x2 + cl général
-- cl général
--
--
-- BIATHLON 3
-- individuel + cl général
-- sprint + cl général
-- relais + cl général
-- mass start + cl général
-- poursuite + cl général
-- cl général
-- sprint x2 cl général
--
-- COMBINÉ NORDIQUE 4
-- individuel + cl général
-- poursuite + cl général
-- par équipe + cl général
-- cl général
--
--
-- FREESTYLE 5
-- bosses + cl général
-- saut big air + cl général
-- ski cross + cl général
-- half pipe + cl général
-- slopestyle
-- acrobatique
-- artistique
-- cl général
--
-- SAUT 6
-- saut spécial + cl général
-- vol à ski + cl général
--
-- SNOWBOARD 8
-- cross + cl général
-- freestyle + cl général
-- alpin  + cl général
-- half pipe + cl général
-- big air
-- slopestyle
-- cl général
--


type MedalType
    = Gold
    | Silver
    | Bronze


type Sport
    = SkiAlpin
    | SkiDeFond
    | Biathlon
    | CombineNordique
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
    , CombineNordique
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
    , medals = []
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

        CombineNordique ->
            "Combiné nordique"

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

        "Combiné nordique" ->
            Just CombineNordique

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
