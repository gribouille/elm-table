module Dynamic exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, src)
import Http exposing (Error)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Table
import Table.Column as Column
import Table.Config as Config
import Url.Builder as Builder


type alias Model =
    Table.Model User


type alias User =
    { id : Int
    , firstname : String
    , lastname : String
    , email : String
    , avatar : String
    }


type alias Payload =
    { page : Int
    , perPage : Int
    , totalPages : Int
    , data : List User
    }


decoder : Decoder Payload
decoder =
    Decode.succeed Payload
        |> required "page" Decode.int
        |> required "per_page" Decode.int
        |> required "total_pages" Decode.int
        |> required "data" (Decode.list decoderUser)


decoderUser : Decoder User
decoderUser =
    Decode.succeed User
        |> required "id" Decode.int
        |> required "first_name" Decode.string
        |> required "last_name" Decode.string
        |> required "email" Decode.string
        |> required "avatar" Decode.string


type Msg
    = OnTableInternal Model
    | OnTableRefresh Model
    | OnData (Result Error Payload)


get : Int -> Cmd Msg
get page =
    Http.get
        { url = Builder.relative [ "api", "users" ] [ Builder.int "page" page ]
        , expect = Http.expectJson OnData decoder
        }


config : Table.Config User () Msg
config =
    Table.dynamic
        OnTableRefresh
        OnTableInternal
        (String.fromInt << .id)
        [ Column.int .id "ID" "" |> Column.withWidth "10px"
        , Column.string .firstname "Firstname" ""
        , Column.string .lastname "Lastname" ""
        , Column.string .email "Email" ""
        , Column.string .avatar "Avatar" "" |> Column.withView (\v _ -> [ img [ src v.avatar ] [] ])
        ]
        |> Config.withSelectionExclusive
        |> Config.withPagination [ 5, 10, 20, 50 ] 10


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = Table.subscriptions config
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Table.init config, get 1 )


view : Model -> Html Msg
view model =
    div [ class "example-dynamic" ] [ Table.view config model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTableRefresh m ->
            let
                p =
                    Table.pagination m
            in
            ( m, get (p.page + 1) )

        OnTableInternal m ->
            ( m, Cmd.none )

        OnData (Ok res) ->
            ( model |> Table.loadedDynamic res.data (res.totalPages * res.perPage), Cmd.none )

        OnData (Err e) ->
            let
                _ =
                    Debug.log "error" e
            in
            ( model, Cmd.none )
