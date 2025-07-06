module Main exposing (main)

import Browser
import Html exposing (Html, div, text, a, nav)
import Html.Attributes exposing (href)
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
                page = case parse routeParser url of
                    Just p -> p
                    Nothing -> NotFound
            in
            ( { model | page = page }, Cmd.none )


-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ nav []
            [ a [ href "#/", Html.Events.onClick (LinkClicked (Browser.Internal (Url.fromString "/" |> Maybe.withDefault (Url.fromString "/" |> Maybe.withDefault (Debug.todo "invalid"))))) ] [ text "Home" ]
            , text " | "
            , a [ href "/sign" ] [ text "Sign" ]
            , text " | "
            , a [ href "/verify" ] [ text "Verify" ]
            , text " | "
            , a [ href "/encrypt" ] [ text "Encrypt" ]
            , text " | "
            , a [ href "/decrypt" ] [ text "Decrypt" ]
            , text " | "
            , a [ href "/keys" ] [ text "Keys" ]
            ]
        , div [] [ renderPage model.page ]
        ]


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
