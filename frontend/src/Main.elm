module Main exposing (main)

import Browser
import Html exposing (Html, a, div, nav, text)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser exposing (Parser, oneOf, s, top, map, parse)

import Pages.Sign as Sign
import Pages.Verify as Verify
import Pages.Encrypt as Encrypt
import Pages.Decrypt as Decrypt
import Pages.Keys as Keys


-- ROUTES

type Page
    = Home
    | SignPage
    | VerifyPage
    | EncryptPage
    | DecryptPage
    | KeysPage
    | NotFound


routeParser : Parser (Page -> a) a
routeParser =
    oneOf
        [ map Home top
        , map SignPage (s "sign")
        , map VerifyPage (s "verify")
        , map EncryptPage (s "encrypt")
        , map DecryptPage (s "decrypt")
        , map KeysPage (s "keys")
        ]


-- MODEL

type alias Model =
    { key : Nav.Key
    , page : Page
    }


-- INIT

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        page =
            case parse routeParser url of
                Just p -> p
                Nothing -> NotFound
    in
    ( { key = key, page = page }, Cmd.none )


-- UPDATE

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked (Browser.Internal url) ->
            ( model, Nav.pushUrl model.key (Url.toString url) )

        LinkClicked (Browser.External href) ->
            ( model, Nav.load href )

        UrlChanged url ->
            let
                page =
                    case parse routeParser url of
                        Just p -> p
                        Nothing -> NotFound
            in
            ( { model | page = page }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ nav []
            [ navLink model.page Home "/" "Home"
            , text " | "
            , navLink model.page SignPage "/sign" "Sign"
            , text " | "
            , navLink model.page VerifyPage "/verify" "Verify"
            , text " | "
            , navLink model.page EncryptPage "/encrypt" "Encrypt"
            , text " | "
            , navLink model.page DecryptPage "/decrypt" "Decrypt"
            , text " | "
            , navLink model.page KeysPage "/keys" "Keys"
            ]
        , div [] [ renderPage model.page ]
        ]


navLink : Page -> Page -> String -> String -> Html Msg
navLink current target url label =
    let
        className =
            if current == target then
                "selected"
            else
                ""
    in
    a
        [ href url
        , class className
        , onClick (LinkClicked (Browser.Internal (Url.fromString url |> Maybe.withDefault (Url "" "" [] Nothing))))
        ]
        [ text label ]


renderPage : Page -> Html msg
renderPage page =
    case page of
        Home -> div [] [ text "Welcome to SIGMA" ]
        SignPage -> Sign.view
        VerifyPage -> Verify.view
        EncryptPage -> Encrypt.view
        DecryptPage -> Decrypt.view
        KeysPage -> Keys.view
        NotFound -> div [] [ text "404 - Page Not Found" ]


-- MAIN

main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
