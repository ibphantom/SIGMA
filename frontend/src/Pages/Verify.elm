module Pages.Verify exposing (Model, Msg(..), init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


-- MODEL

type alias Model =
    { message : String
    , signature : String
    , result : String
    , status : Maybe String
    , loading : Bool
    }

init : Model
init =
    { message = ""
    , signature = ""
    , result = ""
    , status = Nothing
    , loading = False
    }


-- MESSAGES

type Msg
    = MessageChanged String
    | SignatureChanged String
    | Submit
    | VerifyCompleted (Result Http.Error String)


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MessageChanged str ->
            ( { model | message = str }, Cmd.none )

        SignatureChanged str ->
            ( { model | signature = str }, Cmd.none )

        Submit ->
            if String.isEmpty model.message || String.isEmpty model.signature then
                ( { model | status = Just "Message and signature are required." }, Cmd.none )
            else
                ( { model | loading = True, status = Nothing }
                , verifyRequest model.message model.signature
                )

        VerifyCompleted result ->
            case result of
                Ok body ->
                    ( { model | result = body, loading = False, status = Just "Verification complete." }, Cmd.none )

                Err _ ->
                    ( { model | loading = False, status = Just "Verification failed." }, Cmd.none )


-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Verify Signature" ]
        , textarea
            [ placeholder "Message"
            , value model.message
            , onInput MessageChanged
            ]
            []
        , textarea
            [ placeholder "Signature"
            , value model.signature
            , onInput SignatureChanged
            ]
            []
        , button [ onClick Submit, disabled model.loading ]
            [ text (if model.loading then "Verifying..." else "Verify") ]
        , case model.status of
            Just msg -> div [ class "status" ] [ text msg ]
            Nothing -> text ""
        , if not (String.isEmpty model.result) then
            div [ class "result" ]
                [ h3 [] [ text "Verification Result" ]
                , pre [] [ text model.result ]
                ]
          else
            text ""
        ]


-- HTTP

verifyRequest : String -> String -> Cmd Msg
verifyRequest msg sig =
    let
        body =
            Encode.object
                [ ( "message", Encode.string msg )
                , ( "signature", Encode.string sig )
                ]
    in
    Http.post
        { url = "/api/verify"
        , body = Http.jsonBody body
        , expect = Http.expectString VerifyCompleted
        }
