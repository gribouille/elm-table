module Internal.Toolbar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck, onClick)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.State exposing (..)
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens)


view : Config a b msg -> Pipe msg -> Pipe msg -> State -> List (Html msg)
view (Config cfg) pipeExt pipeInt state =
    [ case cfg.pagination of
        ByPage { capabilities } ->
            toolbarMenuPagination pipeExt pipeInt state capabilities

        _ ->
            text ""
    , toolbarMenuColumns cfg.table.columns pipeInt state
    , case cfg.subtable of
        Just (SubTable _ conf) ->
            toolbarMenuSubColumns conf.columns pipeInt state

        Nothing ->
            text ""
    ]


toolbarMenuPagination : Pipe msg -> Pipe msg -> State -> List Int -> Html msg
toolbarMenuPagination pipeExt pipeInt state capabilities =
    toolbarMenuDropdown
        "grt-icon-stories"
        "Pagination"
        (pipeInt <|
            \s ->
                { s
                    | btPagination = not s.btPagination
                    , btColumns = False
                }
        )
        state.btPagination
        (List.map
            (\i ->
                a
                    [ class "dropdown-item"
                    , onClick (pipeExt <| \s -> { s | byPage = i })
                    ]
                    [ text (String.fromInt i)
                    , iff (i == state.byPage)
                        (span [ class "check" ] [ text "✓" ])
                        (text "")
                    ]
            )
            capabilities
        )


toolbarMenuColumns : List (Column a msg) -> Pipe msg -> State -> Html msg
toolbarMenuColumns columns pipeInt state =
    toolbarMenuDropdown
        "gg-menu-grid-r"
        "Columns"
        (pipeInt <|
            \s ->
                { s
                    | btColumns = not s.btColumns
                    , btPagination = False
                    , btSubColumns = False
                }
        )
        state.btColumns
        (List.filterMap (dropdownItem pipeInt state lensTable) <|
            List.map (\(Column c) -> ( c.name, c.hiddable )) columns
        )


toolbarMenuSubColumns : List (Column a msg) -> Pipe msg -> State -> Html msg
toolbarMenuSubColumns columns pipeInt state =
    toolbarMenuDropdown
        "gg-layout-grid-small"
        "Columns of subtable"
        (pipeInt <|
            \s ->
                { s
                    | btSubColumns = not s.btSubColumns
                    , btColumns = False
                    , btPagination = False
                }
        )
        state.btSubColumns
        (List.filterMap
            (dropdownItem pipeInt state lensSubTable)
         <|
            List.map (\(Column c) -> ( c.name, c.hiddable )) columns
        )


dropdownItem : Pipe msg -> State -> Lens State StateTable -> ( String, Bool ) -> Maybe (Html msg)
dropdownItem pipeInt state lens ( name, hiddable ) =
    let
        stateTable =
            lens.get state

        chk =
            List.any ((==) name) stateTable.visible

        visible =
            iff chk
                (List.filter ((/=) name) stateTable.visible)
                (name :: stateTable.visible)

        msg =
            pipeInt <| \s -> lens.set { stateTable | visible = visible } s
    in
    iff hiddable
        (Just
            (a
                [ class "dropdown-item", onClick msg ]
                [ text name
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


toolbarMenuDropdown : String -> String -> msg -> Bool -> List (Html msg) -> Html msg
toolbarMenuDropdown btn tt msg active items =
    div [ id "dropdown", class <| "toolbar-dropdown" ++ iff active " is-active" "" ]
        [ div [ class "dropdown-trigger" ]
            [ a
                [ class "button has-tooltip-arrow"
                , attribute "data-tooltip" tt
                , attribute "aria-haspopup" "true"
                , attribute "aria-controls" "dropdown-menu"
                , onClick msg
                ]
                [ i [ class btn ] [] ]
            ]
        , div [ class "dropdown-menu", id "dropdown-menu", attribute "role" "menu" ]
            [ div [ class "dropdown-content" ] items ]
        ]
