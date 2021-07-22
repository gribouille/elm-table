module Static exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Table
import Table.Column as Column
import Table.Config as Config


type alias Model =
    Table.Model User


type alias User =
    { id : Int
    , firstname : String
    , lastname : String
    , age : Int
    }


type Msg
    = OnTable Model


users : List User
users =
    [ User 1 "Bob" "Leponge" 22
    , User 2 "Ektor" "Plankton" 21
    , User 3 "Mr" "Krabs" 33
    , User 4 "Linus" "Torwald" 43
    , User 5 "Darlene" "Fleming" 26
    , User 6 "Rodney" "Black" 45
    , User 7 "Joy" "Bishop" 23
    , User 8 "Megan" "Bennett" 47
    , User 9 "Tara" "Williams" 52
    , User 10 "Andy" "King" 11
    , User 11 "Leroy" "Fox" 23
    , User 12 "Felicia" "Castillo" 47
    , User 13 "Tammy" "Carter" 10
    , User 14 "Derrick" "Johnston" 32
    , User 15 "Juan" "Little" 45
    ]


config : Table.Config User () Msg
config =
    Table.static
        OnTable
        (String.fromInt << .id)
        [ Column.int .id "ID" ""
        , Column.string .firstname "Firstname" ""
        , Column.string .lastname "Lastname" ""
        , Column.int .age "Age" ""
        ]
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
    ( Table.init config |> Table.loadedStatic users, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "example-static" ] [ Table.view config model ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTable m ->
            ( m, Cmd.none )
