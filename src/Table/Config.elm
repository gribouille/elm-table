module Table.Config exposing
    ( Config
    , static, dynamic
    , withExpand, withSelection, withSelectionFree, withSelectionLinked
    , withSelectionLinkedStrict, withSelectionExclusive
    , withSelectionExclusiveStrict, withPagination, withProgressiveLoading
    , withToolbar, withErrorView, withSubtable
    )

{-| Configuration of the table.

@docs Config


# Constructors

@docs static, dynamic


# Customizations

@docs withExpand, withSelection, withSelectionFree, withSelectionLinked
@docs withSelectionLinkedStrict, withSelectionExclusive
@docs withSelectionExclusiveStrict, withPagination, withProgressiveLoading
@docs withToolbar, withErrorView, withSubtable

-}

import Html exposing (Html)
import Internal.Config
import Internal.Data exposing (Model)
import Table.Column exposing (..)
import Table.Types exposing (..)


{-| Table's configuration (opaque).
-}
type alias Config a b msg =
    Internal.Config.Config a b msg


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


{-| Add an full-width expandable row.
-}
withExpand : Column a msg -> Config a b msg -> Config a b msg
withExpand =
    Internal.Config.withExpand


{-| Enable the selection (see `Selection` type for the different logics).
-}
withSelection : Selection -> Config a b msg -> Config a b msg
withSelection =
    Internal.Config.withSelection


{-| Enable the selection with the _free_ logic (see `Selection` for more details).
-}
withSelectionFree : Config a b msg -> Config a b msg
withSelectionFree =
    Internal.Config.withSelectionFree


{-| Enable the selection with the _linked_ logic (see `Selection` for more details).
-}
withSelectionLinked : Config a b msg -> Config a b msg
withSelectionLinked =
    Internal.Config.withSelectionLinked


{-| Enable the selection with the _linked_ logic (see `Selection` for more details).
-}
withSelectionLinkedStrict : Config a b msg -> Config a b msg
withSelectionLinkedStrict =
    Internal.Config.withSelectionLinkedStrict


{-| Enable the selection with the _exclusive_ logic (see `Selection` for more details).
-}
withSelectionExclusive : Config a b msg -> Config a b msg
withSelectionExclusive =
    Internal.Config.withSelectionExclusive


{-| Enable the selection with the _strict excluive_ logic (see `Selection` for more details).
-}
withSelectionExclusiveStrict : Config a b msg -> Config a b msg
withSelectionExclusiveStrict =
    Internal.Config.withSelectionExclusiveStrict


{-| Enable the pagination and define the page sizes and the detault page size.
-}
withPagination : List Int -> Int -> Config a b msg -> Config a b msg
withPagination =
    Internal.Config.withPagination


{-| Enable the progressive loading pagination (not implemented).
-}
withProgressiveLoading : Int -> Int -> Config a b msg -> Config a b msg
withProgressiveLoading =
    Internal.Config.withProgressiveLoading


{-| Add a custom toolbar.
-}
withToolbar : List (Html msg) -> Config a b msg -> Config a b msg
withToolbar =
    Internal.Config.withToolbar


{-| Define a specific error message.
-}
withErrorView : (String -> Html msg) -> Config a b msg -> Config a b msg
withErrorView =
    Internal.Config.withErrorView


{-| Define a subtable.
-}
withSubtable : (a -> List b) -> (b -> String) -> List (Column b msg) -> Maybe (Column b msg) -> Config a () msg -> Config a b msg
withSubtable =
    Internal.Config.withSubtable
