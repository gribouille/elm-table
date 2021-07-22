module Table exposing
    ( Model, Row, Rows, RowID, init, loaded, loadedDynamic, loadedStatic, loading, failed
    , Pipe, State, Pagination, pagination, selected, subSelected
    , Config, Column, static, dynamic
    , view, subscriptions
    )

{-| Full featured table.


# Data

@docs Model, Row, Rows, RowID, init, loaded, loadedDynamic, loadedStatic, loading, failed


# State

@docs Pipe, State, Pagination, pagination, selected, subSelected


# Configuration

@docs Config, Column, static, dynamic


# View

@docs view, subscriptions

-}

import Html exposing (Html)
import Internal.Column
import Internal.Config
import Internal.Data
import Internal.State
import Internal.Subscription
import Internal.Table
import Table.Types exposing (..)


{-| Model of component (opaque).
-}
type alias Model a =
    Internal.Data.Model a


{-| Pipe for the table's messages to change the state.
-}
type alias Pipe msg =
    Internal.Column.Pipe msg


{-| Internal table's state.
-}
type alias State =
    Internal.State.State


{-| Table's configuration (opaque).
-}
type alias Config a b msg =
    Internal.Config.Config a b msg


{-| Column's configuration (opaque).
-}
type alias Column a msg =
    Internal.Column.Column a msg


{-| Table's row (opaque).
-}
type alias Row a =
    Internal.Data.Row a


{-| List of table's rows (opaque).
-}
type alias Rows a =
    Internal.Data.Rows a


{-| Unique ID of one row.
-}
type alias RowID =
    Internal.State.RowID


{-| Pagination values.
-}
type alias Pagination =
    Internal.State.Pagination


{-| Table's view.
-}
view : Config a b msg -> Model a -> Html msg
view =
    Internal.Table.view


{-| Initialize the table's model.
-}
init : Config a b msg -> Model a
init =
    Internal.Table.init


{-| Load the data in the model with the total number of rows if the data are
incomplete.
-}
loaded : Model a -> List a -> Int -> Model a
loaded =
    Internal.Data.loaded


{-| Similar to `loaded`. Load partial data in the model and specified the total
number of rows.
-}
loadedDynamic : List a -> Int -> Model a -> Model a
loadedDynamic rows total model =
    Internal.Data.loaded model rows total


{-| Similar to `loaded` with all data so `List.length rows == total`.
-}
loadedStatic : List a -> Model a -> Model a
loadedStatic rows model =
    Internal.Data.loaded model rows (List.length rows)


{-| Data loading is in progress.
-}
loading : Model a -> Model a
loading =
    Internal.Data.loading


{-| Data loading has failed.
-}
failed : Model a -> String -> Model a
failed =
    Internal.Data.failed


{-| Get the pagination values from model.
-}
pagination : Model a -> Pagination
pagination =
    Internal.Data.pagination


{-| Table's subscriptions.
-}
subscriptions : Config a b msg -> Model a -> Sub msg
subscriptions =
    Internal.Subscription.subscriptions


{-| Define a configuration for a table with static data (i.e. with all loaded
data at once).
-}
static : (Model a -> msg) -> (a -> String) -> List (Column a msg) -> Config a () msg
static =
    Internal.Config.static


{-| Define a configuration for a table with dynamic data (i.e. with paginated
loaded data).
-}
dynamic : (Model a -> msg) -> (Model a -> msg) -> (a -> String) -> List (Column a msg) -> Config a () msg
dynamic =
    Internal.Config.dynamic


{-| Return the list of selected rows.
-}
selected : Model a -> List RowID
selected =
    Internal.Data.selected


{-| Return the list of selected rows in the sub tables.
-}
subSelected : Model a -> List RowID
subSelected =
    Internal.Data.subSelected
