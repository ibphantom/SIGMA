module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
import Url exposing (Url)
import Url.Parser exposing (..)


-- ROUTES

type Page = Home | Sign | Verify | NotFound

route : Parser (Page -> a) a
route =
    oneOf
        [ map Home top
        , map Sign (s "sign")
        , map Verify (s "verify")
        ]


-- MODEL

type alias Model =
    { page : Page }


-- INIT

init : Url -> Nav.Key -> (Model, Cmd Msg)
init url _ =
    let
        page = case parse route url of
            Just p -> p
            Nothing -> NotFound
    in
    ( { page = page }, Cmd.none )


-- MAIN

main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


-- MSG

type Msg = UrlChanged Url | LinkClicked Browser.UrlRequest


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UrlChanged url ->
            let
                page = case parse route url of
                    Just p -> p
                    Nothing -> NotFound
            in
            ( { model | page = page }, Cmd.none )

        LinkClicked _ ->
            ( model, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    case model.page of
        Home -> div [] [ text "Welcome to SIGMA" ]
        Sign -> div [] [ text "Sign Page" ]
        Verify -> div [] [ text "Verify Page" ]
        NotFound -> div [] [ text "404 - Page Not Found" ]

