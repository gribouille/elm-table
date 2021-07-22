module Internal.Selection exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck)
import Internal.Column exposing (..)
import Internal.Config exposing (..)
import Internal.Data exposing (..)
import Internal.State exposing (..)
import Internal.Util exposing (..)
import Monocle.Lens exposing (Lens, compose)
import Table.Types exposing (..)



--
-- Parent
--


selectionParent : Pipe msg -> Config a b msg -> List (Row a) -> Column a msg
selectionParent pipe config rows =
    Column
        { name = ""
        , abbrev = ""
        , width = "37px"
        , class = "col-selection"
        , sortable = Nothing
        , searchable = Nothing
        , visible = True
        , hiddable = False
        , viewCell = \v ( s, _ ) -> viewParentCell config rows v ( s, pipe )
        , viewHeader = \c ( s, _ ) -> viewParentHeader config rows c ( s, pipe )
        , default = True
        }


viewParentHeader : Config a b msg -> List (Row a) -> Column a msg -> ( State, Pipe msg ) -> List (Html msg)
viewParentHeader config rows _ ( state, pipe ) =
    [ input
        [ class "checkbox"
        , type_ "checkbox"
        , onCheck (\b -> pipe <| \s -> logicParentHeader config rows s b)
        ]
        []
    ]


viewParentCell : Config a b msg -> List (Row a) -> a -> ( State, Pipe msg ) -> List (Html msg)
viewParentCell ((Config cfg) as config) rows value ( state, pipe ) =
    [ input
        [ class "checkbox"
        , type_ "checkbox"
        , checked (List.member (cfg.table.getID value) state.table.selected)
        , onCheck (\b -> pipe <| \s -> logicParentCell config rows value s b)
        ]
        []
    ]


logicParentHeader : Config a b msg -> List (Row a) -> State -> Bool -> State
logicParentHeader (Config cfg) rows state check =
    let
        selected =
            iff check (List.map (\(Row a) -> cfg.table.getID a) rows) []
    in
    case ( cfg.selection, cfg.subtable ) of
        ( Free, Just (SubTable getValues conf) ) ->
            selectAll check conf getValues state rows selected

        ( Linked, Just (SubTable getValues conf) ) ->
            selectAll check conf getValues state rows selected

        ( LinkedStrict, Just (SubTable getValues conf) ) ->
            selectAll check conf getValues state rows selected

        _ ->
            lensTableSelected.set selected state


selectAll check conf getValues state rows selected =
    let
        subselected =
            iff check
                (List.concat
                    (List.map (\(Row x) -> List.map conf.getID (getValues x))
                        rows
                    )
                )
                []
    in
    state |> lensTableSelected.set selected |> lensSubTableSelected.set subselected


lensTableSelected : Lens State (List RowID)
lensTableSelected =
    compose lensTable lensSelected


lensSubTableSelected : Lens State (List RowID)
lensSubTableSelected =
    compose lensSubTable lensSelected


logicParentCell : Config a b msg -> List (Row a) -> a -> State -> Bool -> State
logicParentCell (Config cfg) _ value state check =
    let
        id =
            cfg.table.getID value

        selected =
            state.table.selected

        subSelected =
            state.subtable.selected

        updatedSelected =
            iff check (id :: selected) (List.filter ((/=) id) selected)
    in
    case ( cfg.selection, cfg.subtable ) of
        ( Disable, _ ) ->
            state

        ( Linked, Just (SubTable getValues conf) ) ->
            linkedState conf getValues value subSelected updatedSelected check state

        ( LinkedStrict, Just (SubTable getValues conf) ) ->
            linkedState conf getValues value subSelected updatedSelected check state

        ( Exclusive, _ ) ->
            state
                |> lensTableSelected.set updatedSelected
                |> lensSubTableSelected.set (iff check [] state.subtable.selected)

        ( ExclusiveStrict, _ ) ->
            state
                |> lensTableSelected.set updatedSelected
                |> lensSubTableSelected.set []

        _ ->
            -- by default Free behavior
            state |> lensTableSelected.set updatedSelected


linkedState conf getValues value subSelected updatedSelected check state =
    let
        children =
            List.map (\x -> conf.getID x) (getValues value)
    in
    state
        |> lensTableSelected.set updatedSelected
        |> lensSubTableSelected.set
            (iff check
                (subSelected ++ children)
                (List.filter (\x -> not <| List.member x children) subSelected)
            )



--
-- Child
--


selectionChild : Pipe msg -> Config a b msg -> List (Row b) -> RowID -> Column b msg
selectionChild pipe config rows id =
    Column
        { name = ""
        , abbrev = ""
        , width = "37px"
        , class = "col-selection"
        , sortable = Nothing
        , searchable = Nothing
        , visible = True
        , hiddable = False
        , viewCell = \v ( s, _ ) -> viewChildCell config rows id v ( s, pipe )
        , viewHeader = \c ( s, _ ) -> viewChildHeader config rows id c ( s, pipe )
        , default = True
        }


viewChildHeader : Config a b msg -> List (Row b) -> RowID -> Column b msg -> ( State, Pipe msg ) -> List (Html msg)
viewChildHeader ((Config cfg) as config) rows id _ ( state, pipe ) =
    case cfg.subtable of
        Just (SubTable _ conf) ->
            [ input
                [ class "checkbox"
                , type_ "checkbox"
                , onCheck (\b -> pipe <| \s -> logicChildHeader id config conf rows s b)
                , disabled (cfg.selection == LinkedStrict)
                ]
                []
            ]

        Nothing ->
            []


viewChildCell : Config a b msg -> List (Row b) -> RowID -> b -> ( State, Pipe msg ) -> List (Html msg)
viewChildCell ((Config cfg) as config) rows id value ( state, pipe ) =
    case cfg.subtable of
        Just (SubTable _ conf) ->
            [ input
                [ class "checkbox"
                , type_ "checkbox"
                , checked (List.member (conf.getID value) state.subtable.selected)
                , onCheck (\check -> pipe <| \s -> logicChildCell id config conf rows value s check)
                , disabled (cfg.selection == LinkedStrict)
                ]
                []
            ]

        Nothing ->
            []


logicChildHeader : RowID -> Config a b msg -> ConfTable b msg -> List (Row b) -> State -> Bool -> State
logicChildHeader _ (Config cfg) conf rows state check =
    let
        original =
            lensSubTableSelected.get state

        ids =
            List.map (\(Row a) -> conf.getID a) rows

        selected =
            iff check
                (List.concat [ original, ids ])
                (List.filter (\id -> not <| List.member id ids) original)
    in
    case cfg.selection of
        _ ->
            lensSubTableSelected.set selected state


logicChildCell : RowID -> Config a b msg -> ConfTable b msg -> List (Row b) -> b -> State -> Bool -> State
logicChildCell _ (Config cfg) conf rows value state check =
    let
        id =
            conf.getID value

        selected =
            state.subtable.selected

        updatedSelected =
            iff check (id :: selected) (List.filter ((/=) id) selected)
    in
    case cfg.selection of
        LinkedStrict ->
            state

        Exclusive ->
            state
                |> lensTableSelected.set (iff check [] state.table.selected)
                |> lensSubTableSelected.set updatedSelected

        ExclusiveStrict ->
            let
                rs =
                    List.map (\(Row a) -> conf.getID a) rows

                ss =
                    List.filter (\x -> List.member x rs) selected
            in
            state
                |> lensTableSelected.set []
                |> lensSubTableSelected.set (iff check (id :: ss) (List.filter ((/=) id) ss))

        _ ->
            lensSubTableSelected.set updatedSelected state
