module Model exposing (AdminPageModel, Attachment, Champion, ChampionForm, ChampionPageModel, Champions, Competition(..), EditChampionPageModel, Flags, FormField(..), Medal, MedalType(..), MedalsPageModel, MembersPageModel, Model, Msg(..), Page(..), ProExperience, SelectedFile, Specialty(..), Sport(..), TeamsPageModel, Year(..), competitionFromString, competitionToDisplay, competitionToString, competitionsList, getId, getName, getSpecialtiesForSport, getYear, initMedal, initProExperience, medalTypeFromInt, medalTypeToDisplay, medalTypeToInt, specialtyFromString, specialtyToDisplay, specialtyToString, sportFromString, sportToString, sportsList)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Editable exposing (Editable)
import File exposing (File)
import Graphql.Http
import RemoteData exposing (RemoteData(..), WebData)
import Table
import Url exposing (Url)
import Utils


type alias Model =
    { currentPage : Page
    , key : Nav.Key
    , isAdmin : Bool
    , currentYear : Year
    }


type Page
    = MembersPage MembersPageModel
    | MedalsPage MedalsPageModel
    | TeamsPage TeamsPageModel
    | ChampionPage ChampionPageModel
    | EditChampionPage EditChampionPageModel
    | AdminPage AdminPageModel


type alias MembersPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    , tableState : Table.State
    }


type alias AdminPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    , tableState : Table.State
    }


type alias MedalsPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    , specialty : Maybe Specialty
    , tableState : Table.State
    , currentYear : Year
    , selectedYear : Maybe Year
    }


type alias TeamsPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    , tableState : Table.State
    , currentYear : Year
    , selectedYear : Maybe Year
    }


type alias ChampionPageModel =
    { id : Id
    , champion : RemoteData (Graphql.Http.Error Champion) Champion
    }


type alias EditChampionPageModel =
    { id : Maybe Id
    , champion : RemoteData (Graphql.Http.Error Champion) ChampionForm
    }


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
    , isMember : Bool
    , intro : String
    , profilePicture : Maybe Attachment
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
    , isMember : Bool
    , intro : String
    , profilePicture : Maybe SelectedFile
    }


type Year
    = Year Int


type alias Medal =
    { id : Id
    , competition : Competition
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

        MassStartGeneral ->
            "MassStartGeneral"

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


specialtyToDisplay : Specialty -> String
specialtyToDisplay specialty =
    case specialty of
        Slalom ->
            "Slalom"

        SlalomGeneral ->
            "Slalom cl. général"

        Descente ->
            "Descente"

        DescenteGeneral ->
            "Descente cl. général"

        SuperG ->
            "Super G"

        SuperGGeneral ->
            "SuperG cl. général"

        SuperCombine ->
            "Super combiné"

        SuperCombineGeneral ->
            "Super combiné cl. général"

        Geant ->
            "Géant"

        General ->
            "Cl. général"

        Combine ->
            "Combiné"

        ParEquipe ->
            "Par équipe"

        Individuel ->
            "Individuel"

        IndividuelGeneral ->
            "Individuel cl. général"

        Sprint ->
            "Sprint"

        SprintGeneral ->
            "Sprint cl. général"

        Poursuite ->
            "Poursuite"

        PoursuiteGeneral ->
            "Poursuite cl. général"

        Relais ->
            "Relais"

        RelaisGeneral ->
            "Relais cl. général"

        SprintX2 ->
            "Sprint x2"

        SprintX2General ->
            "Sprint x2 cl. général"

        MassStart ->
            "Mass start"

        MassStartGeneral ->
            "Mass start cl. général"

        ParEquipeGeneral ->
            "Par équipe cl. général"

        Bosses ->
            "Bosses"

        BossesGeneral ->
            "Bosses cl. général"

        SautBigAir ->
            "Saut big air"

        SautBigAirGeneral ->
            "Saut big air cl. général"

        SkiCross ->
            "Ski cross"

        SkiCrossGeneral ->
            "Ski cros cl. général"

        HalfPipe ->
            "Half pipe"

        HalfPipeGeneral ->
            "Half pipe cl. général"

        Slopestyle ->
            "Slopestyle"

        Acrobatique ->
            "Acrobatique"

        Artistique ->
            "Artistique"

        SautSpecial ->
            "Saut spécial"

        SautSpecialGeneral ->
            "Saut spécial cl. général"

        VolASki ->
            "Vol à ski"

        VolASkiGeneral ->
            "Vol à ski cl. général"

        Cross ->
            "Cross"

        CrossGeneral ->
            "Cross cl. général"

        SnowFreestyle ->
            "Freestyle"

        SnowFreestyleGeneral ->
            "Freestyle cl. général"

        SnowAlpin ->
            "Alpin"

        SnowAlpinGeneral ->
            "Alpin cl. général"


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
    | MassStartGeneral
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


getSpecialtiesForSport : Sport -> List Specialty
getSpecialtiesForSport sport =
    case sport of
        SkiAlpin ->
            [ Slalom, SlalomGeneral, Descente, DescenteGeneral, SuperG, SuperGGeneral, SuperCombine, SuperCombineGeneral, Geant, General, Combine, ParEquipe ]

        SkiDeFond ->
            [ Individuel, IndividuelGeneral, Sprint, SprintGeneral, Poursuite, PoursuiteGeneral, Relais, RelaisGeneral, SprintX2, SprintX2General, General ]

        Biathlon ->
            [ Individuel, IndividuelGeneral, Sprint, SprintGeneral, Relais, RelaisGeneral, MassStart, MassStartGeneral, Poursuite, PoursuiteGeneral, SprintX2, SprintX2General, General ]

        CombineNordique ->
            [ Individuel, IndividuelGeneral, Poursuite, PoursuiteGeneral, ParEquipe, ParEquipeGeneral, General ]

        Freestyle ->
            [ Bosses, BossesGeneral, SautBigAir, SautBigAirGeneral, SkiCross, SkiCrossGeneral, HalfPipe, HalfPipeGeneral, Slopestyle, Acrobatique, Artistique, General ]

        Saut ->
            [ SautSpecial, SautSpecialGeneral, VolASki, VolASkiGeneral ]

        Snowboard ->
            [ Cross, CrossGeneral, SnowFreestyle, SnowFreestyleGeneral, SnowAlpin, SnowAlpinGeneral, HalfPipe, HalfPipeGeneral, SautBigAir, Slopestyle, General ]


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
    { id : Id
    , occupationalCategory : String
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


getId : { a | id : Id } -> String
getId { id } =
    case id of
        Id str ->
            str


getName : Champion -> String
getName { firstName, lastName } =
    String.toUpper lastName ++ " " ++ Utils.capitalize firstName


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
    | GotSaveChampionResponse (RemoteData (Graphql.Http.Error (Maybe Champion)) (Maybe Champion))
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
    | SelectedAMedalSpecialty Int String
    | SelectedASpecialty String
    | TableMsg Table.State
    | ChampionSelected Id
    | SelectedAYear String
    | PressedEditProExperienceButton Int
    | PressedEditMedalButton Int
    | BeganFileSelection
    | CancelledFileSelection
    | FileSelectionDone File
    | GotFileUrl String


type FormField
    = FirstName
    | LastName
    | Email
    | Intro
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
    { id = Id "new"
    , occupationalCategory = ""
    , title = ""
    , companyName = ""
    , description = ""
    , website = ""
    , contact = ""
    }


initMedal : Sport -> Year -> Medal
initMedal sport currentYear =
    { id = Id "new"
    , competition = OlympicGames
    , year = currentYear
    , specialty = sport |> getSpecialtiesForSport |> List.head |> Maybe.withDefault Slalom
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


type alias SelectedFile =
    { filename : String
    , base64 : Maybe String
    }


type alias Attachment =
    { filename : String }


type FileType
    = Image
    | PDF
    | Other
