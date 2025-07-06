module Pages.Keys exposing (Model, Msg(..), init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode


-- MODEL

type alias KeyInfo =
    { label : String
    , fingerprint : String
    }

type alias Model =
    { keys : List KeyInfo
    , status : Maybe String
    , loading : Bool
    }

init : ( Model, Cmd Msg )
init =
    ( { keys = [], status = Nothing, loading = False }, fetchKeys )


-- MESSAGES

type Msg
    = GotKeys (Result Http.Error (List KeyInfo))
    | WipeKeys
    | RegenerateKeys
    | KeyOperationCompleted (Result Http.Error String)


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotKeys (Ok keys) ->
            ( { model | keys = keys, loading = False }, Cmd.none )

        GotKeys (Err _) ->
            ( { model | status = Just "Failed to load keys.", loading = False }, Cmd.none )

        WipeKeys ->
            ( { model | loading = True }, performKeyOp "/api/keys/wipe" )

        RegenerateKeys ->
            ( { model | loading = True }, performKeyOp "/api/keys/regenerate" )

        KeyOperationCompleted (Ok msg) ->
            ( { model | status = Just msg, loading = False }, fetchKeys )

        KeyOperationCompleted (Err _) ->
            ( { model | status = Just "Key operation failed.", loading = False }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "GPG Key Management" ]
        , button [ onClick WipeKeys, disabled model.loading ] [ text "Wipe All Keys" ]
        , button [ onClick RegenerateKeys, disabled model.loading ] [ text "Regenerate Keys" ]
        , case model.status of
            Just msg -> div [ class "status" ] [ text msg ]
            Nothing -> text ""
        , if model.loading then
            div [] [ text "Loading..." ]
          else
            div []
                (List.map viewKey model.keys)
        ]


viewKey : KeyInfo -> Html msg
viewKey key =
    div [ class "key-entry" ]
        [ h3 [] [ text key.label ]
        , p [] [ text ("Fingerprint: " ++ key.fingerprint) ]
        ]


-- HTTP

fetchKeys : Cmd Msg
fetchKeys =
    Http.get
        { url = "/api/keys"
        , expect = Http.expectJson GotKeys keyListDecoder
        }

performKeyOp : String -> Cmd Msg
performKeyOp url =
    Http.post
        { url = url
        , body = Http.emptyBody
        , expect = Http.expectString KeyOperationCompleted
        }

keyDecoder : Decode.Decoder KeyInfo
keyDecoder =
    Decode.map2 KeyInfo
        (Decode.field "label" Decode.string)
        (Decode.field "fingerprint" Decode.string)

keyListDecoder : Decode.Decoder (List KeyInfo)
keyListDecoder =
    Decode.list keyDecoder
