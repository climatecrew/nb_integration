module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)


type Msg
    = SubmitEvent


type alias Model =
    { counter : Int
    , email : String
    }


type alias Flags =
    { email : String, access_token : String }


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { counter = 0, email = flags.email }, Cmd.none )


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [ class "nb-integration-container" ]
        [ div [] [ text model.email ]
        , div [ class "event-form" ]
            [ div [] [ label [] [ text "Name:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Intro:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Time Zone:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Start Time:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "End Time:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Capacity:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Venue:", input [ type_ "text" ] [] ] ]
            , div [] [ button [ onClick SubmitEvent ] [ text "Submit Event" ] ]
            ]
        , div [ class "event-list" ]
            [ h2 [] [ text "My Events" ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitEvent ->
            ( model, Cmd.none )
