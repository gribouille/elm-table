module Table exposing
    ( Config, Data, Pipe, Row, Rows(..), State, Status(..), init, loaded
    , Column, Pagination, Sort(..), col, colI, colS, errorDefaultView, pagination, withWidth
    , view, viewHeader, withViewCell
    )

{-| Table component (in progress...).


# Data

@docs Config, Data, Pipe, Row, Rows, State, Status, init, loaded


# Column

@docs Column, Pagination, Sort, col, colI, colS, errorDefaultView, pagination, withWidth


# View

@docs view, viewHeader, withViewCell

-}

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick, onInput)
import Http exposing (Error)
import Internal.Util exposing (..)


{-| TODO
-}
type Status a
    = Loading
    | Loaded a
    | Failed String Error


{-| TODO
-}
type Sort
    = Ascending
    | Descending
    | StandBy


{-| TODO
-}
type Rows a
    = Static (List (Row a))
    | Dynamic (Status (Data a))


{-| TODO
-}
type alias Data a =
    { total : Int
    , rows : List (Row a)
    }


{-| TODO
-}
loaded : Int -> List a -> Status (Data a)
loaded total values =
    Loaded <| Data total (List.map Row values)


{-| TODO
-}
type Row a
    = Row a


{-| TODO
-}
type Column a msg
    = Column
        { name : String
        , abbrev : String
        , width : String
        , sortable : Bool
        , hiddable : Bool
        , searchable : Maybe (a -> String)
        , visible : Bool
        , viewCell : a -> Pipe msg -> List (Html msg)
        , viewHeader : Pipe msg -> List (Html msg)
        , comp : Maybe (a -> a -> Order)
        }


{-| TODO
-}
type alias Pagination =
    { search : String
    , orderBy : String
    , order : Sort
    , page : Int
    , byPage : Int
    }


{-| TODO
-}
type alias Pipe msg =
    ( State, State -> msg )


{-| TODO
-}
type alias Config a msg =
    { pipe : State -> msg
    , columns : List (Column a msg)
    , pagination : Bool
    , numsPage : List Int
    , initialNumPage : Int
    , searchBar : Bool
    , selectNumByPage : Bool
    , hideColumn : Bool
    , onChange : State -> msg
    , errorView : String -> Error -> Html msg
    , toolbar : List (Html msg)
    }


{-| TODO
-}
type alias State =
    { visibleColumns : List String
    , orderBy : Maybe String
    , order : Sort
    , page : Int
    , byPage : Int
    , search : String
    , btPagination : Bool
    , btColumns : Bool
    , tmp : String
    }


{-| TODO
-}
pagination : State -> Pagination
pagination state =
    Pagination state.search
        (Maybe.withDefault "" state.orderBy)
        state.order
        state.page
        state.byPage


{-| TODO
-}
init : Config a msg -> State
init config =
    { visibleColumns =
        List.filterMap
            (\(Column c) ->
                iff c.visible (Just c.name) Nothing
            )
            config.columns
    , orderBy = Nothing
    , order = Ascending
    , page = 0
    , byPage = config.initialNumPage
    , search = ""
    , btPagination = False
    , btColumns = False
    , tmp = ""
    }


{-| TODO
-}
col :
    (a -> a -> Order)
    -> (a -> Html msg)
    -> String
    -> String
    -> Bool
    -> Bool
    -> Maybe (a -> String)
    -> Column a msg
col comp viewCell title_ abbrev sortable hiddable searchable =
    Column
        { name = title_
        , abbrev = abbrev
        , width = ""
        , sortable = sortable
        , searchable = searchable
        , visible = True
        , hiddable = hiddable
        , viewCell = \x _ -> [ viewCell x ]
        , viewHeader = viewHeader abbrev title_ sortable
        , comp = Just comp
        }


{-| TODO
-}
colI : (a -> Int) -> String -> String -> Bool -> Bool -> Column a msg
colI get title_ abbrev sortable hiddable =
    Column
        { name = title_
        , abbrev = abbrev
        , width = ""
        , sortable = sortable
        , searchable = Just (get >> String.fromInt)
        , visible = True
        , hiddable = hiddable
        , viewCell = \x _ -> [ text <| String.fromInt (get x) ]
        , viewHeader = viewHeader abbrev title_ sortable
        , comp = Just <| \a b -> compare (get a) (get b)
        }


{-| TODO
-}
colS : (a -> String) -> String -> String -> Bool -> Bool -> Column a msg
colS get title_ abbrev sortable hiddable =
    Column
        { name = title_
        , abbrev = abbrev
        , width = ""
        , sortable = sortable
        , searchable = Just get
        , visible = True
        , hiddable = hiddable
        , viewCell = \x _ -> [ text (get x) ]
        , viewHeader = viewHeader abbrev title_ sortable
        , comp = Just <| \a b -> compare (get a) (get b)
        }


{-| TODO
-}
withWidth : String -> Column a msg -> Column a msg
withWidth w (Column c) =
    Column { c | width = w }


{-| TODO
-}
withViewCell : (a -> Pipe msg -> List (Html msg)) -> Column a msg -> Column a msg
withViewCell f (Column c) =
    Column { c | viewCell = f }


{-| TODO
-}
viewHeader : String -> String -> Bool -> Pipe msg -> List (Html msg)
viewHeader abbrev title_ sortable ( state, pipe ) =
    [ iff (String.isEmpty abbrev)
        (span [] [ text title_ ])
        (abbr [ title title_ ] [ text abbrev ])
    , iff sortable
        (iff (state.orderBy == Just title_)
            (a
                [ class "sort"
                , onClick <| pipe { state | order = nextOrder state.order }
                ]
                [ text <|
                    case state.order of
                        Ascending ->
                            "↿"

                        Descending ->
                            "⇂"

                        StandBy ->
                            "⇅"
                ]
            )
            (a
                [ class "sort"
                , onClick <| pipe { state | order = Ascending, orderBy = Just title_ }
                ]
                [ text "⇅" ]
            )
        )
        (text "")
    ]



--
-- VIEW
--


{-| TODO
-}
view : Config a msg -> State -> Rows a -> Html msg
view config state rows_ =
    case rows_ of
        Dynamic res ->
            div [ class "grt" ] <|
                header config config.onChange state
                    :: (case res of
                            Loading ->
                                [ div
                                    [ class "spinner" ]
                                    [ span [ class "gg-spinner" ] [] ]
                                ]

                            Loaded { total, rows } ->
                                [ tabularDynamic config state total rows
                                , footer config.onChange state total
                                ]

                            Failed msg err ->
                                [ config.errorView msg err ]
                       )

        Static rows ->
            div [ class "grt" ]
                [ header config config.pipe state
                , tabularStatic config state rows
                , footer config.pipe state (List.length rows)
                ]



-- Header


header : Config a msg -> (State -> msg) -> State -> Html msg
header config pipe state =
    div [ class "field is-grouped header" ]
        [ search config.pipe pipe state
        , div [ class "toolbar-custom" ] config.toolbar
        , toolbar config state
        ]


search : (State -> msg) -> (State -> msg) -> State -> Html msg
search pipe pipeValid state =
    div [ class "control is-expanded has-icons-right toolbar-search" ]
        [ input
            [ class "input"
            , type_ "text"
            , placeholder "Search..."
            , onInput (\s -> pipe { state | tmp = s })
            , onKeyDown (\i -> iff (i == 13) (pipeValid { state | search = state.tmp }) (pipe state))
            ]
            []
        , span [ class "icon is-right" ] [ i [ class "gg-search" ] [] ]
        ]


toolbar : Config a msg -> State -> Html msg
toolbar config state =
    div [ class "control field is-grouped toolbar-table" ] <|
        [ menuPagination config state
        , menuColumns config state
        ]


menuColumns : Config a msg -> State -> Html msg
menuColumns config state =
    dropdown
        "gg-menu-grid-r"
        "Columns"
        (config.pipe { state | btColumns = not state.btColumns, btPagination = False })
        state.btColumns
        (List.filterMap
            (\(Column c) ->
                let
                    chk =
                        List.any ((==) c.name) state.visibleColumns

                    msg =
                        config.pipe
                            { state
                                | visibleColumns =
                                    iff chk
                                        (List.filter ((/=) c.name) state.visibleColumns)
                                        (c.name :: state.visibleColumns)
                            }
                in
                iff c.hiddable
                    (Just
                        (a
                            [ class "dropdown-item"
                            , onClick msg
                            , href ""
                            ]
                            [ text c.name
                            , input
                                [ class "is-checkradio is-pulled-right"
                                , type_ "checkbox"
                                , checked chk
                                , onCheck (\_ -> msg)
                                ]
                                []
                            ]
                        )
                    )
                    Nothing
            )
            config.columns
        )


menuPagination : Config a msg -> State -> Html msg
menuPagination config state =
    dropdown
        "gg-stories"
        "Pagination"
        (config.pipe
            { state
                | btPagination = not state.btPagination
                , btColumns = False
            }
        )
        state.btPagination
        (List.map
            (\i ->
                a
                    [ class "dropdown-item"
                    , onClick (config.onChange { state | byPage = i })
                    , href ""
                    ]
                    [ text (String.fromInt i)
                    , iff (i == state.byPage)
                        (span [ class "check" ] [ text "✓" ])
                        (text "")
                    ]
            )
            config.numsPage
        )


dropdown : String -> String -> msg -> Bool -> List (Html msg) -> Html msg
dropdown btn tt msg active items =
    div [ class <| "control dropdown is-right" ++ iff active " is-active" "" ]
        [ div [ class "dropdown-trigger" ]
            [ a
                [ class "button has-tooltip-arrow"
                , attribute "data-tooltip" tt
                , attribute "aria-haspopup" "true"
                , attribute "aria-controls" "dropdown-menu"
                , onClick msg
                , href ""
                ]
                [ i [ class btn ] [] ]
            ]
        , div
            [ class "dropdown-menu"
            , id "dropdown-menu"
            , attribute "role" "menu"
            ]
            [ div [ class "dropdown-content" ] items ]
        ]



-- Table


tabularDynamic : Config a msg -> State -> Int -> List (Row a) -> Html msg
tabularDynamic config state total rows =
    let
        columns =
            List.filter
                (\(Column c) ->
                    List.member c.name state.visibleColumns
                )
                config.columns
    in
    div [ class "table" ]
        [ table [ class "table is-striped is-hoverable is-fullwidth" ]
            [ thead []
                [ tr [] <|
                    List.map
                        (\(Column c) ->
                            th [] (c.viewHeader ( state, config.onChange ))
                        )
                        columns
                ]
            , tbody [] <|
                List.map
                    (\(Row r) ->
                        tr []
                            (List.map
                                (\(Column c) ->
                                    td [ style "width" c.width ] <|
                                        c.viewCell r ( state, config.pipe )
                                )
                                columns
                            )
                    )
                    rows
            ]
        ]


tabularStatic : Config a msg -> State -> List (Row a) -> Html msg
tabularStatic config state rows =
    let
        columns =
            List.filter
                (\(Column c) -> List.member c.name state.visibleColumns)
                config.columns

        srows =
            iff
                (String.isEmpty state.search)
                rows
                (List.filter
                    (\(Row a) ->
                        List.any
                            (\(Column c) ->
                                case c.searchable of
                                    Nothing ->
                                        False

                                    Just fn ->
                                        String.contains state.search (fn a)
                            )
                            config.columns
                    )
                    rows
                )

        frows =
            srows
                |> sort config.columns state
                |> Array.fromList
                |> Array.slice (state.page * state.byPage) ((state.page + 1) * state.byPage)
                |> Array.toList
    in
    div [ class "tabular" ]
        [ table [ class "table is-striped is-hoverable is-fullwidth" ]
            [ thead []
                [ tr [] <|
                    List.map
                        (\(Column c) ->
                            th [] (c.viewHeader ( state, config.pipe ))
                        )
                        columns
                ]
            , tbody [] <|
                List.map
                    (\(Row r) ->
                        tr []
                            (List.map
                                (\(Column c) ->
                                    td [ style "width" c.width ] <|
                                        c.viewCell r ( state, config.pipe )
                                )
                                columns
                            )
                    )
                    frows
            ]
        ]



-- Footer


footer : (State -> msg) -> State -> Int -> Html msg
footer pipe state total =
    let
        nb =
            floor (toFloat total / toFloat state.byPage) + 1

        ( ia, ib, ic ) =
            pagIndex nb state.page
    in
    div [ class "footer" ]
        [ nav
            [ class "pagination is-centered"
            , attribute "role" "navigation"
            , attribute "aria-label" "pagination"
            ]
            [ ifh (nb > 1) <|
                a
                    [ class <| "pagination-previous" ++ iff (state.page == 0) " is-disabled" ""
                    , onClick <| pipe { state | page = state.page - 1 }
                    , href ""
                    ]
                    [ text "Previous" ]
            , ifh (nb > 1) <|
                a
                    [ class <| "pagination-next" ++ iff (state.page == nb - 1) " is-disabled" ""
                    , onClick <| pipe { state | page = state.page + 1 }
                    , href ""
                    ]
                    [ text "Next page" ]
            , ul [ class "pagination-list" ]
                -- First page
                [ ifh (nb > 3) <|
                    a
                        [ class <| "pagination-link " ++ iff (state.page == 0) "is-current" ""
                        , attribute "aria-label" "Goto page 1"
                        , attribute "aria-current" <| iff (state.page == 0) "page" ""
                        , onClick <| pipe { state | page = 0 }
                        , href ""
                        ]
                        [ text "1" ]
                , ifh (nb > 3) <| span [ class "pagination-ellipsis" ] [ text "…" ]

                -- Middle (m-1) m (m+1)
                , ifh (nb > 2) <|
                    a
                        [ class <| "pagination-link " ++ iff (state.page == ia) "is-current" ""
                        , attribute "aria-label" <| "Goto page " ++ String.fromInt (ia + 1)
                        , attribute "aria-current" <| iff (state.page == ia) "page" ""
                        , onClick <| pipe { state | page = ia }
                        , href ""
                        ]
                        [ text <| String.fromInt (ia + 1) ]
                , ifh (nb > 0) <|
                    a
                        [ class <| "pagination-link " ++ iff (state.page == ib) "is-current" ""
                        , attribute "aria-label" <| "Goto page " ++ String.fromInt (ib + 1)
                        , attribute "aria-current" <| iff (state.page == ib) "page" ""
                        , onClick <| pipe { state | page = ib }
                        , href ""
                        ]
                        [ text <| String.fromInt (ib + 1) ]
                , ifh (nb > 1) <|
                    a
                        [ class <| "pagination-link " ++ iff (state.page == ic) "is-current" ""
                        , attribute "aria-label" <| "Goto page " ++ String.fromInt (ic + 1)
                        , attribute "aria-current" <| iff (state.page == ic) "page" ""
                        , onClick <| pipe { state | page = ic }
                        , href ""
                        ]
                        [ text <| String.fromInt (ic + 1) ]

                -- Last page
                , ifh (nb > 4) <| span [ class "pagination-ellipsis" ] [ text "…" ]
                , ifh (nb > 4) <|
                    a
                        [ class <| "pagination-link " ++ iff (state.page == nb - 1) "is-current" ""
                        , attribute "aria-label" <| "Goto page " ++ String.fromInt nb
                        , onClick <| pipe { state | page = nb - 1 }
                        , href ""
                        ]
                        [ text <| String.fromInt nb ]
                ]
            ]
        ]


pagIndex : Int -> Int -> ( Int, Int, Int )
pagIndex n c =
    if c == 0 then
        if n > 3 then
            let
                m =
                    floor (toFloat n / 2)
            in
            ( m - 1, m, m + 1 )

        else
            ( 0, 1, 2 )

    else if c == 1 then
        if n > 3 then
            ( 1, 2, 3 )

        else
            ( 0, 1, 2 )

    else if c == n - 1 then
        if n > 3 then
            ( n - 4, n - 3, n - 2 )

        else
            ( n - 3, n - 2, n - 1 )

    else if c == n - 2 then
        ( n - 4, n - 3, n - 2 )

    else
        ( c - 1, c, c + 1 )


{-| TODO
-}
errorDefaultView : String -> Error -> Html msg
errorDefaultView msg err =
    div [ class "error" ] [ text (errStr msg err) ]



--
-- SORT
--


sort : List (Column a msg) -> State -> List (Row a) -> List (Row a)
sort columns state rows =
    let
        comp =
            Maybe.andThen (\(Column c) -> c.comp) <|
                find (\(Column c) -> Just c.name == state.orderBy) columns
    in
    case comp of
        Nothing ->
            rows

        Just fn ->
            sortRowsFromStatus fn state.order rows


sortRowsFromStatus : (a -> a -> Order) -> Sort -> List (Row a) -> List (Row a)
sortRowsFromStatus comp order rows =
    case order of
        StandBy ->
            rows

        Descending ->
            sortRows comp rows

        Ascending ->
            List.reverse (sortRows comp rows)


sortRows : (a -> a -> Order) -> List (Row a) -> List (Row a)
sortRows comp rows =
    List.sortWith (\(Row a) (Row b) -> comp a b) rows


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first

            else
                find predicate rest


nextOrder : Sort -> Sort
nextOrder status =
    case status of
        StandBy ->
            Descending

        Descending ->
            Ascending

        Ascending ->
            Descending
