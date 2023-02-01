module Internal.Table exposing (..)

import Array
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.Pagination exposing (..)
import Internal.Selection exposing (..)
import Internal.State exposing (..)
import Internal.Toolbar
import Internal.Util exposing (..)
import Table.Types exposing (..)



--
-- Initialize
--


init : Config a b msg -> Model a
init (Config cfg) =
    let
        fnVisible =
            \(Column { name, default }) -> iff default (Just name) Nothing

        visibleColumns =
            List.filterMap fnVisible cfg.table.columns

        visibleSubColumns =
            Maybe.map
                (\(SubTable _ c) -> List.filterMap fnVisible c.columns)
                cfg.subtable
                |> Maybe.withDefault []
    in
    Model
        { state =
            { orderBy = Nothing
            , order = Ascending
            , page = 0
            , byPage =
                case cfg.pagination of
                    ByPage { initial } ->
                        initial

                    Progressive { initial } ->
                        initial

                    _ ->
                        0
            , search = ""
            , btPagination = False
            , btColumns = False
            , btSubColumns = False
            , table = StateTable visibleColumns [] [] []
            , subtable = StateTable visibleSubColumns [] [] []
            }
        , rows = Rows Loading
        }



--
-- View
--


view : Config a b msg -> Model a -> Html msg
view config ((Model m) as model) =
    let
        pipeInt =
            pipeInternal config model

        pipeExt =
            pipeExternal config model
    in
    div [ class "grt-main" ] <|
        case m.rows of
            Rows Loading ->
                [ tableHeader config pipeExt pipeInt m.state
                , div [ class "grt-spinner" ] [ span [ class "grt-icon-spinner" ] [] ]
                ]

            Rows (Loaded { total, rows }) ->
                [ tableHeader config pipeExt pipeInt m.state
                , tableContent config pipeExt pipeInt m.state rows
                , tableFooter config pipeExt pipeInt m.state total
                ]

            Rows (Failed msg) ->
                [ tableHeader config pipeExt pipeInt m.state, errorView msg ]



--
-- Header
--


tableHeader : Config a b msg -> Pipe msg -> Pipe msg -> State -> Html msg
tableHeader ((Config cfg) as config) pipeExt pipeInt state =
    div [ class "grt-table-header" ]
        [ div [ class "header-search" ] <| headerSearch pipeExt pipeInt
        , div [ class "header-custom" ] cfg.toolbar
        , div [ class "header-toolbar" ] <| Internal.Toolbar.view config pipeExt pipeInt state
        ]


headerSearch : Pipe msg -> Pipe msg -> List (Html msg)
headerSearch pipeExt pipeInt =
    [ input
        [ class "input"
        , type_ "text"
        , placeholder "Search..."
        , onInput
            (\s ->
                pipeInt <|
                    \state ->
                        { state
                            | search = s
                            , btPagination = False
                            , btColumns = False
                        }
            )
        , onKeyDown
            (\i ->
                iff (i == 13)
                    (pipeExt <| \state -> { state | search = state.search })
                    (pipeExt <| \state -> state)
            )
        ]
        []
    , span [ class "icon is-right" ] [ i [ class "gg-search" ] [] ]
    ]



--
-- Content
--


tableContent : Config a b msg -> Pipe msg -> Pipe msg -> State -> List (Row a) -> Html msg
tableContent ((Config cfg) as config) pipeExt pipeInt state rows =
    let
        expandColumn =
            ifMaybe (cfg.table.expand /= Nothing) (expand pipeInt lensTable cfg.table.getID)

        subtableColumn =
            case cfg.subtable of
                Just (SubTable get _) ->
                    Just <| subtable (get >> List.isEmpty) pipeInt lensTable cfg.table.getID

                _ ->
                    Nothing

        selectColumn =
            ifMaybe (cfg.selection /= Disable) (selectionParent pipeInt config rows)

        visibleColumns =
            List.filter
                (\(Column c) -> List.member c.name state.table.visible)
                cfg.table.columns

        columns =
            visibleColumns
                |> prependMaybe subtableColumn
                |> prependMaybe expandColumn
                |> prependMaybe selectColumn

        -- sort by columns
        srows =
            iff (cfg.type_ == Static) (sort cfg.table.columns state rows) rows

        -- filter by search
        filter =
            \rs ->
                iff (String.isEmpty state.search)
                    rs
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
                                cfg.table.columns
                        )
                        rows
                    )

        frows =
            iff (cfg.type_ == Static) (filter srows) srows

        -- cut the results for the pagination
        cut =
            \rs ->
                rs
                    |> Array.fromList
                    |> Array.slice (state.page * state.byPage) ((state.page + 1) * state.byPage)
                    |> Array.toList

        prows =
            iff (cfg.type_ == Static && cfg.pagination /= None) (cut frows) frows
    in
    div [ class "table-content" ]
        [ table []
            [ tableContentHead (cfg.selection /= Disable) pipeExt pipeInt columns state
            , tableContentBody config pipeExt pipeInt columns state prows
            ]
        ]


tableContentHead :
    Bool
    -> Pipe msg
    -> Pipe msg
    -> List (Column a msg)
    -> State
    -> Html msg
tableContentHead hasSelection pipeExt pipeInt columns state =
    thead []
        [ tr [] <|
            List.indexedMap
                (\i ((Column c) as col) ->
                    if i == 0 && hasSelection then
                        th [ style "width" c.width ] <|
                            c.viewHeader col ( state, pipeInt )

                    else
                        th [ style "width" c.width ] <|
                            c.viewHeader col ( state, pipeExt )
                )
                columns
        ]


tableContentBody :
    Config a b msg
    -> Pipe msg
    -> Pipe msg
    -> List (Column a msg)
    -> State
    -> List (Row a)
    -> Html msg
tableContentBody config pipeExt pipeInt columns state rows =
    tbody [] <| List.concat (List.map (tableContentBodyRow config pipeExt pipeInt columns state) rows)


tableContentBodyRow :
    Config a b msg
    -> Pipe msg
    -> Pipe msg
    -> List (Column a msg)
    -> State
    -> Row a
    -> List (Html msg)
tableContentBodyRow ((Config cfg) as config) pipeExt pipeInt columns state (Row r) =
    [ tr [] <|
        List.map
            (\(Column c) ->
                td [ class c.class, style "width" c.width ] <|
                    c.viewCell r ( state, pipeExt )
            )
            columns
    , case ( cfg.table.expand, List.member (cfg.table.getID r) state.table.expanded ) of
        ( Just (Column c), True ) ->
            tr []
                [ td [ colspan (List.length columns) ] <|
                    c.viewCell r ( state, pipeExt )
                ]

        _ ->
            text ""
    , case ( cfg.subtable, List.member (cfg.table.getID r) state.table.subtable ) of
        ( Just (SubTable getValue conf), True ) ->
            tr []
                [ td [ colspan (List.length columns) ]
                    [ subtableContent config
                        pipeExt
                        pipeInt
                        (cfg.table.getID r)
                        conf
                        state
                        (getValue r)
                    ]
                ]

        _ ->
            text ""
    ]


subtableContent :
    Config a b msg
    -> Pipe msg
    -> Pipe msg
    -> RowID
    -> ConfTable b msg
    -> State
    -> List b
    -> Html msg
subtableContent ((Config cfg) as config) pipeExt pipeInt parent subConfig state data =
    let
        expandColumn =
            ifMaybe (subConfig.expand /= Nothing) (expand pipeInt lensTable subConfig.getID)

        rows =
            List.map Row data

        selectColumn =
            ifMaybe (cfg.selection /= Disable) (selectionChild pipeInt config rows parent)

        visibleColumns =
            List.filter
                (\(Column c) -> List.member c.name state.subtable.visible)
                subConfig.columns

        columns =
            visibleColumns
                |> prependMaybe expandColumn
                |> prependMaybe selectColumn
    in
    div [ class "subtable-content" ]
        [ table []
            [ tableContentHead (cfg.selection /= Disable) pipeInt pipeExt columns state
            , subtableContentBody pipeExt subConfig columns state rows
            ]
        ]


subtableContentBody :
    Pipe msg
    -> ConfTable a msg
    -> List (Column a msg)
    -> State
    -> List (Row a)
    -> Html msg
subtableContentBody pipeExt cfg columns state rows =
    tbody [] <| List.concat (List.map (subtableContentBodyRow pipeExt cfg columns state) rows)


subtableContentBodyRow :
    Pipe msg
    -> ConfTable a msg
    -> List (Column a msg)
    -> State
    -> Row a
    -> List (Html msg)
subtableContentBodyRow pipeExt cfg columns state (Row r) =
    [ tr [] <|
        List.map
            (\(Column c) ->
                td [ class c.class, style "width" c.width ] <| c.viewCell r ( state, pipeExt )
            )
            columns
    , case ( cfg.expand, List.member (cfg.getID r) state.subtable.expanded ) of
        ( Just (Column c), True ) ->
            tr []
                [ td [ colspan (List.length columns) ] <| c.viewCell r ( state, pipeExt )
                ]

        _ ->
            text ""
    ]



--
-- Footer
--


tableFooter : Config a b msg -> Pipe msg -> Pipe msg -> State -> Int -> Html msg
tableFooter (Config cfg) pipeExt pipeInt state total =
    if cfg.pagination == None then
        text ""

    else
        tableFooterContent cfg.type_ pipeInt pipeExt state.byPage state.page total



--
-- SORT
--


sort : List (Column a msg) -> State -> List (Row a) -> List (Row a)
sort columns state rows =
    let
        compFn =
            Maybe.andThen (\(Column c) -> c.sortable) <|
                find (\(Column c) -> Just c.name == state.orderBy) columns
    in
    maybe rows (sortRowsFromStatus state.order rows) compFn


sortRowsFromStatus : Sort -> List (Row a) -> (a -> a -> Order) -> List (Row a)
sortRowsFromStatus order rows comp =
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
