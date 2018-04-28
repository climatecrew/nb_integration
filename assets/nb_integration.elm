module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2, table, tr, td)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (field, dict, list, string, array, int, oneOf, decodeString)
import String exposing (join)
import Dict exposing (Dict)


type Msg
    = SubmitEvent
    | FetchEventsResult (Result Http.Error APIResult)
    | CreateEventResult (Result Http.Error APIResult)


type alias Event =
    { id : Int, name : String }


type alias Error =
    { title : String }


type ResultPiece
    = APIEvent Int String
    | APIError String


type alias APIResult =
    { errors : List Error
    , event : Event
    , events : List Event
    }


type alias Model =
    { apiResult : APIResult
    , authorID : Int
    , email : String
    , errors : List Error
    , event : Event
    , events : List Event
    , rootURL : String
    , slug : String
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
            { apiResult = { errors = [], events = [], event = Event 0 "temp" }
            , authorID = flags.authorID
            , email = flags.email
            , event = Event 0 "Name..."
            , events = []
            , errors = []
            , rootURL = flags.rootURL
            , slug = flags.slug
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
        , div [ class "error-container" ] [ errorDisplay model ]
        , div [ class "event-list" ] [ myEvents model ]
        ]


myEvents : Model -> Html Msg
myEvents model =
    div [] <|
        let
            events =
                model.apiResult.events
        in
            if List.length events > 0 then
                [ h2 [] [ text "My Events" ]
                , div []
                    [ table [] (List.map eventRow events)
                    ]
                ]
            else
                []


errorDisplay : Model -> Html Msg
errorDisplay model =
    div [] <|
        let
            errors =
                model.apiResult.errors
        in
            if List.length errors > 0 then
                [ h2 [] [ text "Errors" ]
                , div []
                    [ table [] (List.map errorRow errors)
                    ]
                ]
            else
                []



--partitionResult : Model -> ( List Event, List Error )
--partitionResult model =
--    let
--        f rp x =
--            case rp of
--                APIEvent id name ->
--                    Tuple.mapFirst
--                        (\v ->
--                            (Event id name) :: v
--                        )
--                        x
--
--                APIError title ->
--                    Tuple.mapSecond
--                        (\v ->
--                            (Error title) :: v
--                        )
--                        x
--    in
--        List.foldl (f) ( [], [] ) model.apiResult


eventRow : Event -> Html Msg
eventRow event =
    tr [] [ td [] [ text event.name ] ]


errorRow : Error -> Html Msg
errorRow error =
    tr [] [ td [] [ text error.title ] ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitEvent ->
            ( model, Http.send CreateEventResult (createEvent model) )

        FetchEventsResult (Ok resultPieces) ->
            ( { model | apiResult = resultPieces }, Cmd.none )

        FetchEventsResult (Err err) ->
            ( model, Cmd.none )

        CreateEventResult (Ok resultPiece) ->
            let
                x =
                    Debug.log "CER Ok" "Ok 2"
            in
                ( { model | apiResult = resultPiece }, Cmd.none )

        CreateEventResult (Err err) ->
            let
                x =
                    Debug.log "CER err" "Err 2"
            in
                case err of
                    Http.BadStatus response ->
                        ( model, Cmd.none )

                    _ ->
                        ( model, Cmd.none )


createEvent : Model -> Http.Request APIResult
createEvent model =
    Http.post (eventsURL model)
        Http.emptyBody
        errorsDecoder


getEvents : Model -> Http.Request APIResult
getEvents model =
    Http.get ((eventsURL model) ++ "&author_nb_id=" ++ (toString model.authorID))
        errorsDecoder


eventID =
    field "id" int


eventName =
    field "name" string


eventDecoder =
    field "event" <|
        Json.Decode.map2 Event eventID eventName


eventsDecoder =
    field "data" <|
        list <|
            eventDecoder


errorsDecoder =
    Json.Decode.map (\es -> { errors = es, events = [], event = Event 0 "temp" })
        (field "errors" <|
            list <|
                Json.Decode.map Error (field "title" string)
        )


eventsURL : Model -> String
eventsURL model =
    model.rootURL ++ "/api/events?slug=" ++ model.slug
