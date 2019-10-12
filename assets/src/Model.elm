module Model exposing (..)

import Aisf.Scalar exposing (Id(..))
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Dropdown
import Editable exposing (Editable)
import File exposing (File)
import Graphql.Http
import Menu
import RemoteData exposing (RemoteData(..), WebData)
import Table
import Url exposing (Url)
import Utils


type alias Model =
    { currentPage : Page
    , key : Nav.Key
    , isAdmin : Bool
    , currentYear : Year
    , sectors : RemoteData (Graphql.Http.Error Sectors) Sectors
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
    , searchQuery : Maybe String
    }


type alias AdminPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    , tableState : Table.State
    , searchQuery : Maybe String
    , sector : Maybe Sector
    }


type alias MedalsPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    , specialty : Maybe Specialty
    , tableState : Table.State
    , currentYear : Year
    , selectedYear : Maybe Year
    , searchQuery : Maybe String
    }


type alias TeamsPageModel =
    { champions : RemoteData (Graphql.Http.Error Champions) Champions
    , sport : Maybe Sport
    , tableState : Table.State
    , currentYear : Year
    , selectedYear : Maybe Year
    , searchQuery : Maybe String
    }


type alias ChampionPageModel =
    { id : Id
    , champion : RemoteData (Graphql.Http.Error Champion) Champion
    , medalsTableState : Table.State
    }


type alias EditChampionPageModel =
    { id : Maybe Id
    , champion : RemoteData (Graphql.Http.Error Champion) ChampionForm
    , sectorDropdown : Dropdown.Model
    }


type alias Champions =
    List Champion


type alias Champion =
    { id : Id
    , lastName : String
    , firstName : String
    , email : Maybe String
    , birthDate : Maybe String
    , address : Maybe String
    , phoneNumber : Maybe String
    , website : Maybe String
    , sport : Sport
    , proExperiences : List ProExperience
    , yearsInFrenchTeam : List Year
    , medals : List Medal
    , isMember : Bool
    , intro : Maybe String
    , highlights : List String
    , profilePicture : Maybe Attachment
    , frenchTeamParticipation : Maybe String
    , olympicGamesParticipation : Maybe String
    , worldCupParticipation : Maybe String
    , trackRecord : Maybe String
    , bestMemory : Maybe String
    , decoration : Maybe String
    , background : Maybe String
    , volunteering : Maybe String
    , oldId : Maybe Id
    , pictures : List Picture
    }


type alias Picture =
    { id : Id
    , attachment : Attachment
    }


type alias ChampionForm =
    { id : Id
    , lastName : String
    , firstName : String
    , email : Maybe String
    , birthDate : Maybe String
    , address : Maybe String
    , phoneNumber : Maybe String
    , website : Maybe String
    , sport : Maybe Sport
    , proExperiences : Dict Int (Editable ProExperience)
    , yearsInFrenchTeam : Dict Int (Editable Year)
    , medals : Dict Int (Editable Medal)
    , isMember : Bool
    , intro : Maybe String
    , highlights : Dict Int (Editable String)
    , profilePicture : Maybe Attachment
    , frenchTeamParticipation : Maybe String
    , olympicGamesParticipation : Maybe String
    , worldCupParticipation : Maybe String
    , trackRecord : Maybe String
    , bestMemory : Maybe String
    , decoration : Maybe String
    , background : Maybe String
    , volunteering : Maybe String
    , pictures : List Picture
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
    , title : Maybe String
    , companyName : Maybe String
    , description : Maybe String
    , website : Maybe String
    , contact : Maybe String
    , sectors : List String
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
    | BeganFileSelection Id
    | CancelledFileSelection
    | FileSelectionDone Id File
    | GotFileUrl Id String
    | UpdatedSearchQuery String
    | GotSectors (RemoteData (Graphql.Http.Error Sectors) Sectors)
    | SelectedASector String
    | DropdownStateChanged Menu.Msg
    | UpdatedDropdownQuery String
    | DropdownGotFocus
    | DropdownLostFocus
    | ClosedDropdown
    | RemovedItemFromDropdown String
    | CreatedASectorFromQuery
    | PressedAddHighlightButton
    | PressedEditHighlightButton Int
    | PressedDeleteHighlightButton Int
    | CancelledHighlightEdition Int
    | UpdatedHighlight Int String
    | PressedConfirmHighlightButton Int
    | GoBack
    | PressedEditChampionButton Id
    | PressedAddPictureButton


type FormField
    = FirstName
    | LastName
    | Email
    | Intro
    | FrenchTeamParticipation
    | OlympicGamesParticipation
    | WorldCupParticipation
    | TrackRecord
    | BestMemory
    | Decoration
    | Background
    | Volunteering
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
    , title = Nothing
    , companyName = Nothing
    , description = Nothing
    , website = Nothing
    , contact = Nothing
    , sectors = []
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


type alias Attachment =
    { filename : String, base64 : Maybe String }


type FileType
    = Image
    | PDF
    | Other


type alias Sectors =
    List Sector


type alias Sector =
    { id : Id
    , name : String
    }


findSectorByName : List Sector -> String -> Maybe Sector
findSectorByName sectors name =
    sectors
        |> List.filter (.name >> (==) name)
        |> List.head


acceptableSectors : Maybe String -> Sectors -> List String
acceptableSectors query sectors =
    sectors
        |> List.map .name
        |> List.filter
            (\name ->
                name
                    |> String.toLower
                    |> String.contains (query |> Maybe.withDefault "" |> String.toLower)
            )


createSector : String -> Sector
createSector name =
    Sector (Id "new") name


getSportIcon : Sport -> String
getSportIcon sport =
    "picto_"
        ++ (case sport of
                SkiAlpin ->
                    "alpin"

                SkiDeFond ->
                    "fond"

                Biathlon ->
                    "biathlon"

                CombineNordique ->
                    "nordique"

                Freestyle ->
                    "freestyle"

                Saut ->
                    "saut"

                Snowboard ->
                    "snowboard"
           )
        ++ ".png"


getMedalIcon : Competition -> MedalType -> String
getMedalIcon competition medalType =
    (case competition of
        OlympicGames ->
            "jo"

        WorldChampionships ->
            "champion_du_monde"

        WorldCup ->
            "globe"
    )
        ++ (case medalType of
                Gold ->
                    "_or"

                Silver ->
                    "_ar"

                Bronze ->
                    "_br"
           )
        ++ ".png"


getIsMemberIcon : Bool -> String
getIsMemberIcon isMember =
    if isMember then
        "logo_aisf.png"

    else
        "logo_aisf_nb.png"


initPicture : Picture
initPicture =
    { id = Id "new"
    , attachment = Attachment "" Nothing
    }
