port module Example1 exposing (main)

{-| Example with Bootstrap modals to manage the item in the table.
-}

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Table
import Data.Data exposing (User)
import Data.Users exposing (data)


-- Port to toggle the Bootstrap modal with JS. 
port toggleModal : String -> Cmd msg


--
-- MODEL
--

config : Table.Config User Msg
config =
  { pipe = TableState
  , getRowId = .login
  , columns =
    [ Table.checkboxColumn  (.login)
    , Table.stringColumn "Login"  (.login)
    , Table.stringColumn "Firstname" (.firstname)
    , Table.stringColumn "Lastname" (.lastname)
    , Table.stringColumn "Email" (.email)
    , Table.stringColumn "Phone" (.phone)
    ]
  , toolbar = 
    { search        = True
    , selectColumns = True
    , actions       = 
      [ Table.actionDefault (Modal Add) "success" "plus" "Add"
      , Table.actionDefault (Modal (Delete [])) "danger" "trash-o" "Delete"
      ]
    }
  , footerView = Table.defaultFooter
  }


type alias Model = 
  { rows  : List (Table.Row User)
  , state : Table.State
  , user  : User
  }


init : (Model, Cmd Msg)
init = 
  let
    (st, rw) = Table.initRows (.login) data
  in
    { rows = rw, state = st, user = User "" "" "" "" "" } ! []


--
-- MESSAGES
--

type Action = Add | Delete (List String)

type Field = Login | Firstname | Lastname | Email | Phone

type Msg 
  = TableState Table.State
  | Modal Action
  | Do Action
  | Set Field String


modalAction : Action -> Cmd msg
modalAction action =
  case action of 
    Add -> toggleModal "modal-add"
    Delete _ -> toggleModal "modal-del"


setUserProp : User -> Field -> String -> User
setUserProp user field value =
  case field of
    Login     -> { user | login = value }
    Firstname -> { user | firstname = value }
    Lastname  -> { user | lastname = value }
    Email     -> { user | email = value }
    Phone     -> { user | phone = value }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of 
    TableState state -> { model | state = state } ! []
    Modal action -> model ! [ modalAction action ] 
    Do action -> case action of
      -- here add request to server to add an user
      Add -> 
        if String.isEmpty model.user.login then 
          model ! [ modalAction action ]
        else
          { model 
          | user = User "" "" "" "" ""
          , rows = (Table.Row model.user) :: model.rows   -- just for example
          } ! [ modalAction action ]
      -- here add request to server to delete the selected users
      Delete logins -> 
        { model 
        -- just for example
        | rows = List.filter (not << (\(Table.Row u) -> List.member u.login logins)) model.rows
        , state = model.state
        } ! [ modalAction action ]
    Set field value -> { model | user = setUserProp model.user field value } ! []


--
-- VIEW
--

view : Model -> H.Html Msg
view { state, rows } = 
  let
    selected = List.map (.login) <| Table.getSelectedRows (.login) state rows
    -- add validation system to check the input field in the add modal
  in
    H.div [] 
    [ Table.view config state rows 
    , viewModal "modal-add" "Add a new user" (Do Add) contentModalAdd
    , viewModal "modal-del" "Delete the selected users" (Do (Delete selected)) (contentModalDel selected)
    ] 


contentModalAdd : List (H.Html Msg)
contentModalAdd = 
  [ H.form []
    [ H.div [ HA.class "form-group" ] 
      [ viewInput "login" "Login" (Set Login)
      , viewInput "firstname" "Firstname" (Set Firstname)
      , viewInput "lastname" "Lastname" (Set Lastname)
      , viewInput "email" "Email" (Set Email)
      , viewInput "phone" "Phone" (Set Phone)
      ]
    ]
  ]


viewInput : String -> String -> (String -> msg) -> H.Html msg
viewInput id title cb =
  H.div [ HA.class "form-group" ]
  [ H.label [ HA.for id ] [ H.text title ]
  , H.input
    [ HA.type_ "text"
    , HA.class "form-control"
    , HA.id id
    , HE.onInput cb
    , HA.placeholder title ] []
  ]


contentModalDel : List String -> List (H.Html Msg)
contentModalDel logins = 
  [ H.div [] [ H.text "Delete the next users:"]
  , H.ul [] <| List.map (\x -> H.li [] [ H.text x]) logins
  ]


viewModal : String -> String -> msg -> List (H.Html msg) -> H.Html msg
viewModal id_ title submitMsg content =
  H.div 
  [ HA.class "modal fade"
  , HA.id id_
  , HA.tabindex -1
  , HA.attribute "data-keyboard" "false"
  , HA.attribute "data-backdrop" "static"
  , HA.attribute "role" "dialog" ] 
  [ H.div [ HA.class "modal-dialog", HA.attribute "role" "document" ]
    [ H.div [ HA.class "modal-content" ]
      [ H.div [ HA.class "modal-header" ]
        [ H.h5 [ HA.class "modal-title" ] [ H.text title ]
        , H.button 
          [ HA.type_ "button"
          , HA.class "close"
          , HA.attribute "data-dismiss" "modal" ]
          [ H.span [] [ H.text "×" ] ] 
        ]
      , H.div [ HA.class "modal-body" ] content
      , H.div [ HA.class "modal-footer" ]
        [ H.button 
          [ HA.type_ "button"
          , HA.class "btn btn-secondary"
          , HA.attribute "data-dismiss" "modal" 
          ] [ H.text "Close"]
        , H.button 
          [ HA.type_ "button"
          , HA.class "btn btn-primary"
          , HE.onClick submitMsg 
          ] [ H.text "Save changes" ]
        ]
      ] 
    ]
  ]


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
