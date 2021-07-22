module Subtable exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onCheck)
import Movies exposing (..)
import Table
import Table.Column as Column
import Table.Config as Config
import Table.Types exposing (Selection(..))



type alias Model =
    { selection : Selection
    , table : Table.Model Movie
    }


type Msg
    = OnTable (Table.Model Movie)
    | OnSelection Selection


columnsMovie =
    [ Column.string .id "ID" "" |> Column.withDefault False
    , Column.string .title "Title" ""
    , Column.string .original_title "Original title" ""
    , Column.string .original_title_romanised "Original title romanised" ""
    , Column.string .director "Director" ""
    , Column.string .producer "Producer" ""
    , Column.int .release_date "Release date" ""
    , Column.int .running_time "Running time" ""
    , Column.int .rt_score "RT score" ""
    ]


columnsPerson =
    [ Column.string .id "ID" "" |> Column.withDefault False
    , Column.string .name "name" ""
    , Column.string .gender "Gender" ""
    , Column.default "Age"
        ""
        (\x _ ->
            [ case x.age of
                Nothing ->
                    text ""

                Just v ->
                    text <| String.fromInt v
            ]
        )
    , Column.string .eye_color "Eye color" ""
    , Column.string .hair_color "Hair color" ""
    ]


radio : String -> Selection -> Selection -> Html Msg
radio n exp got =
    label [ class "radio" ]
        [ input
            [ type_ "radio"
            , name "radio"
            , onCheck (\_ -> OnSelection exp)
            , checked (got == exp)
            ]
            []
        , text <| " " ++ n
        ]


config : Selection -> Table.Config Movie Person Msg
config s =
    Table.static
        OnTable
        .id
        columnsMovie
        |> Config.withSelection s
        |> Config.withExpand (Column.string .description "Description" "")
        |> Config.withPagination [ 5, 10, 20, 50 ] 10
        |> Config.withSubtable .people .id columnsPerson Nothing
        |> Config.withToolbar
            [ div [ class "control example-subtable-toolbar" ]
                [ radio "Disable" Disable s
                , radio "Free" Free s
                , radio "Linked" Linked s
                , radio "Linked Strict" LinkedStrict s
                , radio "Exclusive" Exclusive s
                , radio "Exclusive Strict" ExclusiveStrict s
                ]
            ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \m -> Table.subscriptions (config m.selection) m.table
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { selection = Disable
      , table = Table.init (config Disable) |> Table.loadedStatic movies
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    let
        _ =
            Debug.log "selection" model.selection
    in
    div [ class "example-subtable" ] [ Table.view (config model.selection) model.table ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTable m ->
            ( { model | table = m }, Cmd.none )

        OnSelection s ->
            ( { model | selection = s }, Cmd.none )
