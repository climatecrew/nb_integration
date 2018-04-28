module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2, table, tr, td)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (field, dict, list, string, array, int, map2)
import String exposing (join)
import Dict exposing (Dict)


type Msg
    = SubmitEvent
    | FetchEventsResult (Result Http.Error (List Event))
    | CreateEventResult (Result Http.Error Event)


type alias Event =
    { id : Int
    , name : String
    }


type alias Model =
    { email : String
    , authorID : Int
    , rootURL : String
    , slug : String
    , events : List Event
    , event : Event
    }


type alias Flags =
    { authorID : Int, email : String, access_token : String, rootURL : String, slug : String }


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
    let
        model =
            { authorID = flags.authorID
            , email = flags.email
            , rootURL = flags.rootURL
            , slug = flags.slug
            , events = []
            , event = constructEvent 0 "New Event"
            }
    in
        ( model, Http.send FetchEventsResult (getEvents model) )


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
            , div [] [ label [] [ text "Contact Name:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Contact Email:", input [ type_ "text" ] [] ] ]
            , div [] [ button [ onClick SubmitEvent ] [ text "Submit Event" ] ]
            ]
        , div [ class "event-list" ] [ myEvents model ]
        ]


myEvents : Model -> Html Msg
myEvents model =
    div [] <|
        if List.length model.events > 0 then
            [ h2 [] [ text "My Events" ]
            , div []
                [ table [] (List.map eventRow model.events)
                ]
            ]
        else
            []


eventRow : Event -> Html Msg
eventRow event =
    tr [] [ td [] [ text event.name ] ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitEvent ->
            ( model, Http.send CreateEventResult (createEvent model) )

        FetchEventsResult (Ok events) ->
            ( { model | events = events }, Cmd.none )

        FetchEventsResult (Err err) ->
            ( model, Cmd.none )

        CreateEventResult (Ok event) ->
            ( { model | event = event }, Cmd.none )

        CreateEventResult (Err err) ->
            ( model, Cmd.none )


createEvent : Model -> Http.Request Event
createEvent model =
    Http.post (eventsURL model)
        Http.emptyBody
        (field "data" <|
            field "event" <|
                map2 constructEvent eventID eventName
        )


getEvents : Model -> Http.Request (List Event)
getEvents model =
    Http.get ((eventsURL model) ++ "&author_nb_id=" ++ (toString model.authorID))
        (field "data" <|
            list <|
                field "event" <|
                    map2 constructEvent eventID eventName
        )


constructEvent : Int -> String -> Event
constructEvent id name =
    { id = id, name = name }


eventID =
    field "id" int


eventName =
    field "name" string


eventsURL : Model -> String
eventsURL model =
    model.rootURL ++ "/api/events?slug=" ++ model.slug
