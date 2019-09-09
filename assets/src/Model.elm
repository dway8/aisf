module Model exposing (Champion, ChampionForm, ChampionPageModel, Champions, Competition(..), Flags, FormField(..), ListPageModel, Medal, MedalType(..), Model, Msg(..), NewChampionPageModel, Page(..), ProExperience, Route(..), Specialty(..), Sport(..), Year(..), competitionFromString, competitionToDisplay, competitionToString, competitionsList, getId, getYear, initChampionForm, initMedal, initProExperience, medalTypeFromInt, medalTypeToDisplay, medalTypeToInt, specialtyFromString, specialtyToString, sportFromString, sportToString, sportsList)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Editable exposing (Editable)
import Graphql.Http
import RemoteData exposing (RemoteData(..), WebData)
import Url exposing (Url)


type alias Model =
    { currentPage : Page
    , key : Nav.Key
    , isAdmin : Bool
    , currentYear : Year
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
    { champion : ChampionForm
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
    , yearsInFrenchTeam : List Year
    , medals : List Medal
    }


type alias ChampionForm =
    { id : Id
    , lastName : String
    , firstName : String
    , email : String
    , sport : Maybe Sport
    , proExperiences : Dict Int (Editable ProExperience)
    , yearsInFrenchTeam : Dict Int (Editable Year)
    , medals : Dict Int (Editable Medal)
    }


type Year
    = Year Int


type alias Medal =
    { competition : Competition
    , year : Year
    , specialty : Specialty
    , medalType : MedalType
    }


type Competition
    = OlympicGames
    | WorldChampionships
    | WorldCup


competitionsList : List Competition
competitionsList =
    [ OlympicGames, WorldChampionships, WorldCup ]


getYear : Year -> Int
getYear (Year year) =
    year


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


competitionToString : Competition -> String
competitionToString competition =
    case competition of
        OlympicGames ->
            "OlympicGames"

        WorldChampionships ->
            "WorldChampionships"

        WorldCup ->
            "WorldCup"


competitionToDisplay : Competition -> String
competitionToDisplay competition =
    case competition of
        OlympicGames ->
            "Jeux Olympiques"

        WorldChampionships ->
            "Championnats du monde"

        WorldCup ->
            "Coupe du monde"


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


medalTypeToInt : MedalType -> Int
medalTypeToInt medalType =
    case medalType of
        Gold ->
            1

        Silver ->
            2

        Bronze ->
            3


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


specialtyToString : Specialty -> String
specialtyToString specialty =
    case specialty of
        Slalom ->
            "Slalom"

        SlalomGeneral ->
            "SlalomGeneral"

        Descente ->
            "Descente"

        DescenteGeneral ->
            "DescenteGeneral"

        SuperG ->
            "SuperG"

        SuperGGeneral ->
            "SuperGGeneral"

        SuperCombine ->
            "SuperCombine"

        SuperCombineGeneral ->
            "SuperCombineGeneral"

        Geant ->
            "Geant"

        General ->
            "General"

        Combine ->
            "Combine"

        ParEquipe ->
            "ParEquipe"

        Individuel ->
            "Individuel"

        IndividuelGeneral ->
            "IndividuelGeneral"

        Sprint ->
            "Sprint"

        SprintGeneral ->
            "SprintGeneral"

        Poursuite ->
            "Poursuite"

        PoursuiteGeneral ->
            "PoursuiteGeneral"

        Relais ->
            "Relais"

        RelaisGeneral ->
            "RelaisGeneral"

        SprintX2 ->
            "SprintX2"

        SprintX2General ->
            "SprintX2General"

        MassStart ->
            "MassStart"

        ParEquipeGeneral ->
            "ParEquipeGeneral"

        Bosses ->
            "Bosses"

        BossesGeneral ->
            "BossesGeneral"

        SautBigAir ->
            "SautBigAir"

        SautBigAirGeneral ->
            "SautBigAirGeneral"

        SkiCross ->
            "SkiCross"

        SkiCrossGeneral ->
            "SkiCrossGeneral"

        HalfPipe ->
            "HalfPipe"

        HalfPipeGeneral ->
            "HalfPipeGeneral"

        Slopestyle ->
            "Slopestyle"

        Acrobatique ->
            "Acrobatique"

        Artistique ->
            "Artistique"

        SautSpecial ->
            "SautSpecial"

        SautSpecialGeneral ->
            "SautSpecialGeneral"

        VolASki ->
            "VolASki"

        VolASkiGeneral ->
            "VolASkiGeneral"

        Cross ->
            "Cross"

        CrossGeneral ->
            "CrossGeneral"

        SnowFreestyle ->
            "SnowFreestyle"

        SnowFreestyleGeneral ->
            "SnowFreestyleGeneral"

        SnowAlpin ->
            "SnowAlpin"

        SnowAlpinGeneral ->
            "SnowAlpinGeneral"


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
    { isAdmin : Bool
    , currentYear : Int
    }


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
    | PressedDeleteProExperienceButton Int
    | UpdatedProExperienceField Int FormField String
    | PressedAddYearInFrenchTeamButton
    | SelectedAYearInFrenchTeam Int String
    | PressedAddMedalButton
    | PressedDeleteMedalButton Int
    | SelectedACompetition Int String
    | SelectedAMedalYear Int String


initChampionForm : ChampionForm
initChampionForm =
    { id = Id "new"
    , lastName = ""
    , firstName = ""
    , email = ""
    , sport = Nothing
    , proExperiences = Dict.empty
    , yearsInFrenchTeam = Dict.empty
    , medals = Dict.empty
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


initMedal : Year -> Medal
initMedal currentYear =
    { competition = OlympicGames
    , year = currentYear
    , specialty = Slalom
    , medalType = Gold
    }


medalTypeToDisplay : MedalType -> String
medalTypeToDisplay medalType =
    case medalType of
        Gold ->
            "Or"

        Silver ->
            "Argent"

        Bronze ->
            "Bronze"
