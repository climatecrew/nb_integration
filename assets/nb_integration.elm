module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (list, string)


type Msg
    = SubmitEvent
    | FetchEvents
    | FetchEventsResult (Result Http.Error (List String))


type alias Model =
    { counter : Int
    , email : String
    , rootURL : String
    , slug : String
    }


type alias Flags =
    { email : String, access_token : String, rootURL : String, slug : String }


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
    ( { counter = 0
      , email = flags.email
      , rootURL = flags.rootURL
      , slug = flags.slug
      }
    , Cmd.none
    )


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
            , div [] [ button [ onClick FetchEvents ] [ text "Fetch Events" ] ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitEvent ->
            ( model, Cmd.none )

        FetchEvents ->
            ( model, Http.send FetchEventsResult (getEvents model) )

        FetchEventsResult (Ok events) ->
            ( model, Cmd.none )

        FetchEventsResult (Err _) ->
            ( model, Cmd.none )


getEvents : Model -> Http.Request (List String)
getEvents model =
    Http.get (model.rootURL ++ "/api/events?slug=" ++ model.slug) (list string)
