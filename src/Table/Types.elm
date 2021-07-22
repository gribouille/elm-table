module Table.Types exposing (Selection(..), Type(..), Sort(..), Status(..))

{-| Common types.

@docs Selection, Type, Sort, Status

-}


{-| Type of selection.


## `Disable`

No selection.


## `Free`

Free selection i.e. with no constraint on the parents and children rows.


## `Linked`

Auto select all children rows if the parent is selected.


## `LinkedStrict`

Similar to `Linked` but cannot unselect the children rows.


## `Exclusive`

Parents and children rows cannot get mixed up. It is possible to select the
children of different parents.


## `ExclusiveStrict`

Similar to `Exclusive` but it is not possible to select the children of different
parents.

-}
type Selection
    = Disable
    | Free -- no rule
    | Linked -- select a parent => select the children
    | LinkedStrict -- similar to Linked but cannot unselect the children
    | Exclusive -- child or parent
    | ExclusiveStrict -- child of multiple parents forbidden


{-| Type of data loading.
-}
type Type
    = Static
    | Dynamic


{-| Sort status.
-}
type Sort
    = Ascending
    | Descending
    | StandBy


{-| Data loading status.
-}
type Status a
    = Loading
    | Loaded a
    | Failed String
