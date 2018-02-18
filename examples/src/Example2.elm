module Example2 exposing (main)

{-| Example with a custom column. -}


import Html as H
import Html.Attributes as HA
import Table
import Data.Data exposing (Log, Level(..))
import Data.Logs exposing (data)

--
-- MODEL
--

toId : Log -> String
toId = 
  .id >> toString


config : Table.Config Log Msg
config =
  { pipe = TableState
  , getRowId = toId
  , columns =
    [ Table.invisibleColumn "id" toId
    , Table.stringColumn "Date" (.date)
    , Table.customColumn "Level" "auto" (.level) (H.text "Level") viewLevel
    , Table.stringColumn "Message" (.message)
    ]
  , toolbar = 
    { search        = True
    , selectColumns = True
    , actions       = []
    }
  , footerView = Table.defaultFooter
  }


type alias Model = 
  { state: Table.State
  , rows:  List (Table.Row Log)
  }

init : (Model, Cmd Msg)
init = 
  let
    (st, rw) = Table.initRows toId data
  in
    { state = st, rows = rw } ! []


--
-- MESSAGES
--

type Msg = TableState Table.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of 
    TableState state -> { model | state = state } ! []

--
-- VIEW
--

view : Model -> H.Html Msg
view { rows, state } = 
  H.div [] [ Table.view config state rows ] 


viewLevel : Level -> H.Html msg
viewLevel level =
  case level of
    Info     -> span "text-success" "INFO"
    Warning  -> span "text-warning" "WARN"
    Error    -> span "text-danger" "ERNO"
    Debug    -> span "text-info" "DEBUG"


span : String -> String -> H.Html msg
span cls txt =
  H.span [ HA.class cls, HA.style [("font-family", "monospace")] ] [ H.text txt ]

--
-- MAIN
--

main : Program Never Model Msg 
main =
  H.program
    { init = init
    , update = update
    , view = view
    , subscriptions = \_ -> Sub.none
    }
