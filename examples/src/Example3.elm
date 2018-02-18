module Example3 exposing (main)

{-| Example with many rows (but not too much :)) -}

import Html as H
import Table
import Data.Data exposing (File)
import Data.Files exposing (data)

--
-- MODEL
--

config : Table.Config File Msg
config =
  { pipe = TableState
  , getRowId = (.path)
  , columns =
    [ Table.stringColumn "File" (.path)
    , Table.stringWidthColumn "200px" "Date" (.date)
    , Table.stringWidthColumn "100px" "Permission" (.permission)
    ]
  , toolbar = 
    { search        = True
    , selectColumns = True
    , actions       = []
    }
  , footerView = Table.defaultFooter
  }


type alias Model = 
  { rows   : List (Table.Row File)
  , state  : Table.State
  }


init : (Model, Cmd Msg)
init = 
  let
    (st, rw) = Table.initRows (.path) data
  in
    { state = st, rows = rw } ! []


--
-- MESSAGES
--

type Msg 
  = TableState Table.State


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
