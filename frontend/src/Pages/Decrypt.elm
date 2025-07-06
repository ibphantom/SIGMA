module Pages.Decrypt exposing (Model, Msg(..), init, update, view)

import Browser.Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


-- MODEL

type alias Model =
    { input : String
    , result : String
    , status : Maybe String
    , loading : Bool
    }

init : Model
init =
    { input = ""
    , result = ""
    , status = Nothing
    , loading = False
    }


-- MESSAGES

type Msg
    = InputChanged String
    | Submit
    | DecryptCompleted (Result Http.Error String)


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged str ->
            ( { model | input = str }, Cmd.none )

        Submit ->
            if String.isEmpty model.input then
                ( { model | status = Just "Input cannot be empty." }, Cmd.none )
            else
                ( { model | loading = True, status = Nothing }
                , decryptRequest model.input
                )

        DecryptCompleted result ->
            case result of
                Ok body ->
                    ( { model | result = body, loading = False, status = Just "Decryption successful." }, Cmd.none )

                Err _ ->
                    ( { model | loading = False, status = Just "Decryption failed." }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Decrypt Message" ]
        , textarea
            [ placeholder "Enter encrypted text..."
            , value model.input
            , onInput InputChanged
            ]
            []
        , button [ onClick Submit, disabled model.loading ]
            [ text (if model.loading then "Decrypting..." else "Decrypt") ]
        , case model.status of
            Just msg -> div [ class "status" ] [ text msg ]
            Nothing -> text ""
        , if not (String.isEmpty model.result) then
            div [ class "result" ]
                [ h3 [] [ text "Decrypted Output" ]
                , pre [] [ text model.result ]
                ]
          else
            text ""
        ]


-- HTTP

decryptRequest : String -> Cmd Msg
decryptRequest message =
    let
        body =
            Encode.object [ ( "message", Encode.string message ) ]
    in
    Http.post
        { url = "/api/decrypt"
        , body = Http.jsonBody body
        , expect = Http.expectString DecryptCompleted
        }
