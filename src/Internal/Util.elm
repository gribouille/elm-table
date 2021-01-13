module Internal.Util exposing (..)

import Html exposing (Attribute, Html, text)
import Html.Events exposing (keyCode, on)
import Http exposing (Error(..))
import Json.Decode as Json


iff : Bool -> a -> a -> a
iff cond a b =
    if cond then
        a

    else
        b


ifh : Bool -> Html msg -> Html msg
ifh c a =
    iff c a (text "")


errStr : String -> Error -> String
errStr msg err =
    case err of
        BadUrl s ->
            msg ++ ": bad url: " ++ s

        Timeout ->
            msg ++ ": timeout"

        NetworkError ->
            msg ++ ": network error"

        BadStatus s ->
            msg ++ ": bad status: " ++ String.fromInt s

        BadBody s ->
            msg ++ ": bad body: " ++ s


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)
