module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, text)

type alias Model = {}

type Msg = NoOp

init : () -> (Model, Cmd Msg)
init _ = ({}, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp -> (model, Cmd.none)

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [text "SIGMA - Secure Identity & GPG Media Authority"]
        , div [] [text "Cryptographic platform loading..."]
        ]

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
