module Table exposing (..)

-- TODO: restrict public interface

{-| A customizable ELM Bootstrap Table component.

For usage example, see [here](https://github.com/gribouille/elm-table). 

## Model
@docs State, Row, getSelectedRows, initState, initRows, RowId, hideColumn
@docs selectAllRows, sortRows, sortRowsFromStatus

## Configuration
@docs Config, Column, ColumnInternal, SortStatus, ToolbarConfig, ActionConfig 
@docs nextSortStatus, defaultFooter, checkboxColumn, invisibleColumn
@docs stringColumn, stringWidthColumn, customColumn, actionDefault
@docs ColumnName, checkRowState, showColumn

## View
@docs view, toolbarView, toolbarViewSearch, viewCellCheckbox, viewCellInvisible 
@docs viewCellText, viewColumnCheckbox, viewColumnHide, viewColumnString 
@docs viewDefaultAction, viewSelectColumns, viewSelectColumnsItem, viewTable 
@docs viewTableBody, viewTableBodyRow, viewTableHead, viewTableHeadItemSort

## Other
@docs maybe, onClickEvent, optional, sort, sortLink
-}

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode
import List.Extra as LE
import Dict exposing (Dict)
import Dict


--
-- MODEL
--

{-| -}
type alias ColumnName = String

{-| -}
type alias RowId      = String


{-| State for internal messages. -}
type alias State =
  { sortedColumn : (ColumnName, SortStatus)   -- msg to sort a column
  , selected     : Dict String Bool           -- msg to select one row
  , search       : String                     -- msg to filter rows
  , hidedColumns : List ColumnName            -- msg to hide column
  }


{-| Embed the data with row states. -}
type Row a = Row a


{-| Return the selected rows of table. -}
getSelectedRows : (a -> String) -> State -> List (Row a) -> List a
getSelectedRows toId state rows =
  List.map (\(Row d) -> d)
  <| List.filter (\(Row d) ->
      Maybe.withDefault False (Dict.get (toId d) state.selected)
    ) rows


{-| Initialize the table state. -}
initState : State
initState =
  { sortedColumn = ("", StandBy)
  , selected     = Dict.empty
  , search       = ""
  , hidedColumns = []
  }


{-| Helper to create multiple rows. -}
initRows : (a -> String) -> List a -> (State, List (Row a))
initRows getRowId values  =
  let
    state = initState
  in
    ( { state | selected = Dict.fromList (List.map (\v -> (getRowId v, False)) values) }
    , List.map Row values
    )


--
-- CONFIGURATION
--

{-| Configuration of table.

Table --- msg ---> Parent
        ( pipe )

-}
type alias Config a msg =
  { pipe        : State -> msg          -- forward the messages to parent
  , getRowId    : a -> String           -- get the id from the data
  , columns     : List (Column a msg)   -- columns configuration
  , toolbar     : ToolbarConfig msg     -- toolbar configuration
  , footerView  : H.Html msg            -- custom footer view
  }


{-| Column configuration. -}
type Column a msg = Column (ColumnInternal a msg)


{-|
  sortable  : could be sortable
  indexable : indexable for search filtering
  hidable   : selectColumns options must be true
-}
type alias ColumnInternal a msg =
  { name          : String
  , getValue      : a -> String
  , headerView    : (State -> msg) -> State -> List (H.Html msg)
  , cellView      : a -> (State -> msg) -> State -> List (H.Html msg)
  , width         : String
  , sortable      : Bool
  , indexable     : Bool
  , hidable       : Bool
  }


{-| Sorting column state. -}
type SortStatus
  = StandBy       -- ↕
  | Descending    -- ↓
  | Ascending     -- ↑


{-| Toolbar configuration. -}
type alias ToolbarConfig msg =
  { search        : Bool
  , selectColumns : Bool
  , actions       : List (ActionConfig msg)
  }


{-| Action configuration in the toolbar. -}
type ActionConfig msg = ActionConfig (State -> H.Html msg)


{-| Get the next sort status

      ↕ --> ↓ --> ↑
            ^-----|
-}
nextSortStatus : SortStatus -> SortStatus
nextSortStatus status =
  case status of
    StandBy     -> Descending
    Descending  -> Ascending
    Ascending   -> Descending


{-| Default footer of table. -}
defaultFooter : H.Html msg
defaultFooter = H.text ""


{-| Column with checkbox to select multiple rows. -}
checkboxColumn : (a -> String) -> Column a msg
checkboxColumn getId =
  Column
  { name        = "checkbox"
  , getValue    = always ""
  , headerView  = viewColumnCheckbox
  , cellView    = viewCellCheckbox getId
  , width       = "15px"
  , sortable    = False
  , indexable   = False
  , hidable     = False
  }


{-| Invisible column. -}
invisibleColumn : String -> (a -> String) -> Column a msg
invisibleColumn name getValue =
  Column
  { name        = name
  , getValue    = always ""
  , headerView  = viewColumnHide
  , cellView    = viewCellInvisible
  , width       = "auto"
  , sortable    = False
  , indexable   = False
  , hidable     = False
  }


{-| Standard column configuration to render the string data. -}
stringColumn : String -> (a -> String) -> Column a msg
stringColumn name getValue =
  stringWidthColumn "auto" name getValue


{-| Similar to `stringColumn` but with a custom width. -}
stringWidthColumn : String -> String -> (a -> String) -> Column a msg
stringWidthColumn width name getValue =
  Column
  { name        = name
  , getValue    = getValue
  , headerView  = viewColumnString name
  , cellView    = viewCellText getValue
  , width       = width
  , sortable    = True
  , indexable   = True
  , hidable     = True
  }


{-| Column width custom header and cell rendering. -}
customColumn : String -> String -> (a -> b) -> H.Html msg -> (b -> H.Html msg) -> Column a msg
customColumn name width getValue renderHeader renderCell =
  Column
  { name        = name
  , getValue    = toString << getValue
  , headerView  = (\_ _ -> [ renderHeader ])
  , cellView    = (\data _ _ -> [ (renderCell << getValue ) data ])
  , width       = width
  , sortable    = True
  , indexable   = True
  , hidable     = True
  }


{-| Helper to create an action configuration with the color of Bootstrap
(primary, success, danger, ...) and the icon of font-awesome (plus, minus, ...).

Example:

  actionDefault "success" "lock"
-}

actionDefault : msg -> String -> String -> String -> ActionConfig msg
actionDefault actionMsg color icon tooltip =
  ActionConfig (viewDefaultAction color icon tooltip actionMsg)


--
-- VIEWS
--

{-| Main table view. -}
view : Config a msg -> State -> List (Row a) -> H.Html msg
view config state rows =
  let
    -- get funcs of indexed columns to get value from data
    funcs = List.filterMap (\(Column col) -> maybe col.indexable col.getValue) config.columns

    -- filter the rows from user's search
    currentRows =
      List.filter (\(Row data) ->
        List.any (
          ((|>) data) >> (String.contains state.search)
        ) funcs
      ) rows
      |> sort config.columns state  -- sort by column
      -- |> selected state.selected    -- selected rows

  in
    H.div [ HA.class "elm-table" ]
    [ toolbarView config state
    , viewTable config state currentRows
    ]

{-| -}
toolbarView : Config a msg -> State -> H.Html msg
toolbarView {pipe, columns, toolbar} state =
  H.form [ HA.class "d-flex toolbar" ] <| List.concat
  [ [ optional toolbar.search (toolbarViewSearch pipe state) ]
  , List.map (\(ActionConfig view) -> view state) toolbar.actions
  , [ optional toolbar.selectColumns (viewSelectColumns columns pipe state) ]
  ]

{-| -}
toolbarViewSearch : (State -> msg) -> State -> H.Html msg
toolbarViewSearch pipe state =
  H.input
  [ HA.type_ "text"
  , HE.onInput (\val -> pipe { state | search = val } )
  , HA.class "form-control"
  , HA.placeholder "Search..."] []

{-| -}
viewSelectColumns : List (Column a msg) -> (State -> msg) -> State -> H.Html msg
viewSelectColumns columns pipe state =
  H.div [ HA.class "dropdown" ]
  [ H.button
    [ HA.type_ "button"
    , HA.class "btn btn-outline-secondary btn-sm"
    , HA.href "#"
    , HA.attribute "data-toggle" "dropdown"
    ] [ H.i [ HA.class "fa fa-th" ] [] ]
  , H.div [ HA.class "dropdown-menu dropdown-menu-right" ]
    <| List.map (\(Column col) -> viewSelectColumnsItem col pipe state)
    <| List.filter (\(Column col) -> col.hidable) columns
  ]

{-| -}
viewSelectColumnsItem : ColumnInternal a msg -> (State -> msg) -> State -> H.Html msg
viewSelectColumnsItem col pipe state =
  let
    isHided = List.member col.name state.hidedColumns
    -- TODO: not optimal, pre calculate the 2 state before to raise message
    toggleMsg = if isHided then showColumn col.name else hideColumn col.name
  in
    H.a
    [ HA.class "dropdown-item d-flex justify-content-between text-left"
    , HA.href "#"
    , onClickEvent (pipe (toggleMsg state))
    ]
    [ H.text col.name
    , if isHided then
        H.span [ HA.class "text-secondary" ] [ H.i [ HA.class "fa fa-square-o fa-fw" ] [] ]
      else
        H.span [ HA.class "text-success" ] [ H.i [ HA.class "fa fa-check-square-o fa-fw" ] [] ]
    ]

{-| -}
hideColumn : String -> State -> State
hideColumn name state =
  { state | hidedColumns = name :: state.hidedColumns }

{-| -}
showColumn : String -> State -> State
showColumn name state =
  { state | hidedColumns = List.filter ((/=) name) state.hidedColumns }

{-| -}
viewTable : Config a msg -> State -> List (Row a) -> H.Html msg
viewTable config state rows =
  let
    columns =
      List.map (\(Column col) -> col) config.columns
      |> List.filter (not << ((flip List.member) state.hidedColumns) << (.name))
  in
  H.table [ HA.class "table table-sm table-stripped" ]
  [ viewTableHead columns config.pipe state
  , viewTableBody columns config.getRowId config.pipe state rows
  , config.footerView
  ]

{-| -}
viewTableHead : List (ColumnInternal a msg) -> (State -> msg) -> State -> H.Html msg
viewTableHead columns pipe state =
  H.thead []
  [ H.tr [] <| List.map (\{name, sortable, headerView, width} ->
      let
        (stateName, stateStatus) = state.sortedColumn
        status = if name == stateName then stateStatus else StandBy
        sortIcon = optional sortable
          <| viewTableHeadItemSort status name pipe state
      in
        H.th [HA.style [("width", width)]] <| (headerView pipe state) ++ [sortIcon]
    ) columns
  ]

{-| -}
viewTableHeadItemSort : SortStatus -> ColumnName -> (State -> msg) -> State -> H.Html msg
viewTableHeadItemSort status =
  case status of
    StandBy     -> sortLink "fa fa-fw fa-sort"      "#c8c8ca"
    Descending  -> sortLink "fa fa-fw fa-sort-desc" "#7a7a7f"
    Ascending   -> sortLink "fa fa-fw fa-sort-asc"  "#7a7a7f"

{-| -}
sortLink : String -> String -> ColumnName -> (State -> msg) -> State -> H.Html msg
sortLink cls color name pipe state =
  let
      (_, status) = state.sortedColumn
      clickMsg = pipe {state | sortedColumn = (name, nextSortStatus status)}
  in
    H.a [ HA.href "#" , onClickEvent clickMsg ]
    [ H.span [ HA.style [("color", color)] ] [ H.i [ HA.class cls ] [] ] ]

{-| -}
viewTableBody : List (ColumnInternal a msg) -> (a -> String) -> (State -> msg) -> State -> List (Row a) -> H.Html msg
viewTableBody columns getRowId pipe state rows =
  H.tbody [] <| List.map (viewTableBodyRow columns getRowId pipe state) rows

{-| -}
viewTableBodyRow : List (ColumnInternal a msg) -> (a -> String) -> (State -> msg) -> State -> Row a -> H.Html msg
viewTableBodyRow columns getRowId pipe state (Row data) =
  H.tr [] <| List.map (\col-> H.td [] <| col.cellView data pipe state) columns


-- Column views

{-| -}
viewColumnHide : (State -> msg) -> State -> List (H.Html msg)
viewColumnHide _ _ =
  [ H.text "" ]

{-| -}
viewColumnString : String -> (State -> msg) -> State -> List (H.Html msg)
viewColumnString name _ _ =
  [ H.text name ]

{-| -}
viewColumnCheckbox : (State -> msg) -> State -> List (H.Html msg)
viewColumnCheckbox pipe state =
  [ H.input
    [ HA.type_ "checkbox"
    , HE.onCheck (pipe << selectAllRows state)
    ] []
  ]

{-| -}
selectAllRows : State -> Bool -> State
selectAllRows state value =
  { state | selected = Dict.map (\_ _ -> value) state.selected }


-- Cell views

{-| -}
viewCellInvisible : a -> (State -> msg) -> State -> List (H.Html msg)
viewCellInvisible _ _ _ = []

{-| -}
viewCellText : (a -> String) -> a -> (State -> msg) -> State -> List (H.Html msg)
viewCellText toStr data _ _ =
  [ H.text (toStr data) ]

{-| -}
viewCellCheckbox : (a -> String) -> a -> (State -> msg) -> State -> List (H.Html msg)
viewCellCheckbox toStr data pipe state =
  [ H.input
    [ HA.type_ "checkbox"
    , HE.onCheck (pipe << (checkRowState (toStr data) state))
    , HA.checked <| Maybe.withDefault False (Dict.get (toStr data) state.selected)
    ] []
  ]

{-| -}
checkRowState : String -> State -> Bool -> State
checkRowState id state value =
   { state | selected = Dict.insert id value state.selected}

-- Actions

{-| -}
viewDefaultAction : String -> String -> String -> msg -> (State -> H.Html msg)
viewDefaultAction bsColor faIcon tooltip actionMsg =
  (\_ ->
    H.button
    [ HA.type_ "button"
    , HE.onClick actionMsg
    , HA.class ("btn btn-sm btn-outline-" ++ bsColor)
    , HA.attribute "data-toggle" "tooltip"
    , HA.attribute "data-placement" "bottom"
    , HA.title tooltip ] [ H.i [ HA.class ("fa fa-" ++ faIcon) ] [] ]
  )

--
-- UTILS
--

{-| -}
maybe : Bool -> a -> Maybe a
maybe cond val = if cond then Just val else Nothing

{-| -}
onClickEvent : msg -> H.Attribute msg
onClickEvent evt = HE.onWithOptions "click"
  { stopPropagation = True,  preventDefault = True } (Decode.succeed evt)

{-| -}
optional : Bool -> H.Html msg -> H.Html msg
optional cond comp = if cond then comp else H.text ""


--
-- SORT
--

{-| Sort the rows. -}
sort : List (Column a msg) -> State -> List (Row a) -> List (Row a)
sort columns state rows =
  let
      (columnName, columnStatus) = state.sortedColumn
      getValue = Maybe.map (\(Column col) -> col.getValue)
        <| LE.find (\(Column col) -> col.name == columnName) columns
  in
    case getValue of
      Nothing   -> rows
      Just func -> sortRowsFromStatus columnStatus func rows

{-| -}
sortRowsFromStatus : SortStatus -> (a -> String) -> List (Row a) -> List (Row a)
sortRowsFromStatus status getValue rows =
  case status of
    StandBy    -> rows
    Descending -> sortRows getValue rows
    Ascending  -> List.reverse (sortRows getValue rows)

{-| -}
sortRows : (a -> String) -> List (Row a) -> List (Row a)
sortRows getValue rows =
  List.sortBy (\(Row data) -> getValue data) rows
