module Internal.Config exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Internal.Column exposing (..)
import Internal.Data exposing (..)
import Internal.State exposing (..)
import Table.Types exposing (..)


type Pagination
    = ByPage { capabilities : List Int, initial : Int }
    | Progressive { initial : Int, step : Int } -- TODO: no implemented
    | None


type SubTable a b msg
    = SubTable (a -> List b) (ConfTable b msg)


type Config a b msg
    = Config (ConfigInternal a b msg)


type alias ConfigInternal a b msg =
    { type_ : Type
    , selection : Selection
    , onChangeExt : Model a -> msg
    , onChangeInt : Model a -> msg
    , table : ConfTable a msg
    , pagination : Pagination
    , subtable : Maybe (SubTable a b msg)
    , errorView : String -> Html msg
    , toolbar : List (Html msg)
    }


type alias ConfTable a msg =
    { columns : List (Column a msg)
    , getID : a -> String
    , expand : Maybe (Column a msg)
    }


config : Type -> Selection -> (Model a -> msg) -> (Model a -> msg) -> ConfTable a msg -> Config a () msg
config t s oe oi c =
    Config
        { type_ = t
        , selection = s
        , onChangeExt = oe
        , onChangeInt = oi
        , table = c
        , pagination = None
        , subtable = Nothing
        , errorView = errorView
        , toolbar = []
        }


static : (Model a -> msg) -> (a -> String) -> List (Column a msg) -> Config a () msg
static onChange getID columns =
    Config
        { type_ = Static
        , selection = Disable
        , onChangeExt = onChange
        , onChangeInt = onChange
        , table = ConfTable columns getID Nothing
        , pagination = None
        , subtable = Nothing
        , errorView = errorView
        , toolbar = []
        }


dynamic : (Model a -> msg) -> (Model a -> msg) -> (a -> String) -> List (Column a msg) -> Config a () msg
dynamic onChangeExt onChangeInt getID columns =
    Config
        { type_ = Dynamic
        , selection = Disable
        , onChangeExt = onChangeExt
        , onChangeInt = onChangeInt
        , table = ConfTable columns getID Nothing
        , pagination = None
        , subtable = Nothing
        , errorView = errorView
        , toolbar = []
        }


withExpand : Column a msg -> Config a b msg -> Config a b msg
withExpand col (Config c) =
    let
        t =
            c.table
    in
    Config { c | table = { t | expand = Just col } }


withSelection : Selection -> Config a b msg -> Config a b msg
withSelection s (Config c) =
    Config { c | selection = s }


withSelectionFree : Config a b msg -> Config a b msg
withSelectionFree (Config c) =
    Config { c | selection = Free }


withSelectionLinked : Config a b msg -> Config a b msg
withSelectionLinked (Config c) =
    Config { c | selection = Linked }


withSelectionLinkedStrict : Config a b msg -> Config a b msg
withSelectionLinkedStrict (Config c) =
    Config { c | selection = LinkedStrict }


withSelectionExclusive : Config a b msg -> Config a b msg
withSelectionExclusive (Config c) =
    Config { c | selection = Exclusive }


withSelectionExclusiveStrict : Config a b msg -> Config a b msg
withSelectionExclusiveStrict (Config c) =
    Config { c | selection = ExclusiveStrict }


withPagination : List Int -> Int -> Config a b msg -> Config a b msg
withPagination capabilities initial (Config c) =
    Config { c | pagination = ByPage { capabilities = capabilities, initial = initial } }


withProgressiveLoading : Int -> Int -> Config a b msg -> Config a b msg
withProgressiveLoading initial step (Config c) =
    Config { c | pagination = Progressive { initial = initial, step = step } }


withToolbar : List (Html msg) -> Config a b msg -> Config a b msg
withToolbar t (Config c) =
    Config { c | toolbar = t }


withErrorView : (String -> Html msg) -> Config a b msg -> Config a b msg
withErrorView t (Config c) =
    Config { c | errorView = t }


withSubtable :
    (a -> List b)
    -> (b -> String)
    -> List (Column b msg)
    -> Maybe (Column b msg)
    -> Config a () msg
    -> Config a b msg
withSubtable getValues getID columns expand (Config c) =
    Config
        { type_ = c.type_
        , selection = c.selection
        , onChangeExt = c.onChangeExt
        , onChangeInt = c.onChangeInt
        , table = c.table
        , pagination = c.pagination
        , subtable = Just <| SubTable getValues { columns = columns, getID = getID, expand = expand }
        , errorView = c.errorView
        , toolbar = c.toolbar
        }


errorView : String -> Html msg
errorView msg =
    div [ class "table-data-error" ] [ text msg ]


pipeInternal : Config a b msg -> Model a -> Pipe msg
pipeInternal (Config { onChangeInt }) (Model { rows, state }) fn =
    onChangeInt <| Model { rows = rows, state = fn state }


pipeExternal : Config a b msg -> Model a -> Pipe msg
pipeExternal (Config { onChangeExt }) (Model { rows, state }) fn =
    onChangeExt <| Model { rows = rows, state = fn state }
