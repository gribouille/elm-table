module Internal.Util exposing (..)

import Html exposing (Attribute, Html, b, text)
import Html.Events exposing (keyCode, on)
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


onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger =
    on "keydown" (Json.map tagger keyCode)


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


maybe : b -> (a -> b) -> Maybe a -> b
maybe default fn value =
    case value of
        Nothing ->
            default

        Just x ->
            fn x


ifMaybe : Bool -> a -> Maybe a
ifMaybe c a =
    if c then
        Just a

    else
        Nothing


prependMaybe : Maybe a -> List a -> List a
prependMaybe m l =
    case m of
        Just a ->
            a :: l

        Nothing ->
            l
