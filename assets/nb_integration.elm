module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2, table, tr, td, select, option, span)
import Html.Attributes exposing (class, type_, value, step, id, selected)
import Html.Events exposing (onClick, onInput)
import Http exposing (jsonBody)
import Json.Decode exposing (field, dict, list, string, array, int, oneOf, decodeString, succeed)
import Json.Encode as JE exposing (Value, encode, object)
import String exposing (join)
import Dict exposing (Dict)


type Msg
    = SubmitEvent
    | FetchEventsResult (Result Http.Error APIResult)
    | CreateEventResult (Result Http.Error APIResult)
    | Name String
    | Day String
    | Hour BorderTime String
    | Minute BorderTime String
    | Meridiem BorderTime String


type alias Event =
    { id : Int, name : String, startTime : String, startTimestamp : EditingTimestamp, endTimestamp : EditingTimestamp }


defaultEvent : Event
defaultEvent =
    { id = 0
    , name = "Event Name..."
    , startTime = "2018-09-03"
    , startTimestamp = defaultStartTimestamp
    , endTimestamp = defaultEndTimestamp
    }


type alias EditingTimestamp =
    { border : BorderTime, ymd : String, hour : Int, minute : Int, meridiem : String }


defaultStartTimestamp : EditingTimestamp
defaultStartTimestamp =
    { border = StartTime, ymd = "2018-09-03", hour = 1, minute = 0, meridiem = "PM" }


defaultEndTimestamp : EditingTimestamp
defaultEndTimestamp =
    { border = EndTime, ymd = "2018-09-03", hour = 4, minute = 0, meridiem = "PM" }


type alias Error =
    { title : String }


type BorderTime
    = StartTime
    | EndTime


type ResultPiece
    = APIEvent Int String
    | APIError String


type alias APIResult =
    { errors : List Error
    , event : Maybe Event
    , events : List Event
    }


defaultAPIResult : APIResult
defaultAPIResult =
    { errors = [], event = Nothing, events = [] }


type alias Model =
    { apiResult : APIResult
    , authorID : Int
    , email : String
    , event : Maybe Event
    , events : List Event
    , rootURL : String
    , slug : String
    , loading : Bool
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
            { apiResult = { errors = [], events = [], event = Nothing }
            , authorID = flags.authorID
            , email = flags.email
            , event = Just defaultEvent
            , events = []
            , rootURL = flags.rootURL
            , slug = flags.slug
            , loading = True
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
            [ div []
                [ label []
                    [ text "Name:"
                    , input [ type_ "text", onInput Name ] []
                    ]
                ]
            , div [] [ label [] [ text "Intro:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Time Zone:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Date: ", selectDay ] ]
            , div [] [ label [] [ selectTime StartTime (currentTimestamp model StartTime) ] ]
            , div [] [ label [] [ selectTime EndTime (currentTimestamp model EndTime) ] ]
            , div [] [ label [] [ text "Capacity:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Venue:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Contact Name:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Contact Email:", input [ type_ "text" ] [] ] ]
            , div [] [ button [ onClick SubmitEvent ] [ text "Submit Event" ] ]
            ]
        , div [ id "display-event" ]
            [ div [] [ text <| "Start Time: " ++ formatTimestamp model.event StartTime ]
            , div [] [ text <| "End Time: " ++ formatTimestamp model.event EndTime ]
            ]
        , loadingSpinner model
        , div [ class "error-container" ] [ errorDisplay model ]
        , div [ class "event-list" ] [ myEvents model ]
        ]


currentTimestamp : Model -> BorderTime -> EditingTimestamp
currentTimestamp model borderTime =
    case model.event of
        Just ev ->
            case borderTime of
                StartTime ->
                    ev.startTimestamp

                EndTime ->
                    ev.endTimestamp

        Nothing ->
            case borderTime of
                StartTime ->
                    defaultStartTimestamp

                EndTime ->
                    defaultEndTimestamp


padTimePart : Int -> String
padTimePart num =
    String.padLeft 2 '0' <| toString num


formatTimestamp : Maybe Event -> BorderTime -> String
formatTimestamp mEvent borderTime =
    case mEvent of
        Just ev ->
            let
                timestamp =
                    case borderTime of
                        StartTime ->
                            ev.startTimestamp

                        EndTime ->
                            ev.endTimestamp
            in
                serializeTimestamp timestamp

        Nothing ->
            ""


serializeTimestamp : EditingTimestamp -> String
serializeTimestamp timestamp =
    let
        hour24 =
            case timestamp.meridiem of
                "AM" ->
                    if timestamp.hour == 12 then
                        0
                    else
                        timestamp.hour

                otherwise ->
                    if timestamp.hour == 12 then
                        timestamp.hour
                    else
                        timestamp.hour + 12
    in
        timestamp.ymd
            ++ "T"
            ++ padTimePart hour24
            ++ ":"
            ++ padTimePart timestamp.minute
            ++ ":00"
            ++ "-04:00"


selectDay : Html Msg
selectDay =
    span []
        [ span [] [ text "September" ]
        , select
            [ onInput Day ]
            [ option [ value "2018-09-03" ] [ text "3 Monday" ]
            , option [ value "2018-09-04" ] [ text "4 Tuesday" ]
            , option [ value "2018-09-05" ] [ text "5 Wednesday" ]
            , option [ value "2018-09-06" ] [ text "6 Thursday" ]
            , option [ value "2018-09-07" ] [ text "7 Friday" ]
            ]
        , span [] [ text "2018" ]
        ]


selectTime : BorderTime -> EditingTimestamp -> Html Msg
selectTime borderTime timestamp =
    let
        ( labelText, hour, minute, meridiem ) =
            case borderTime of
                StartTime ->
                    ( span [] [ text "Start Time" ]
                    , [ id "startHour", onInput (Hour StartTime) ]
                    , [ id "startMinute", onInput (Minute StartTime) ]
                    , [ id "startMeridiem", onInput (Meridiem StartTime) ]
                    )

                EndTime ->
                    ( span [] [ text "End Time" ]
                    , [ id "endHour", onInput (Hour EndTime) ]
                    , [ id "endMinute", onInput (Minute EndTime) ]
                    , [ id "endMeridiem", onInput (Meridiem EndTime) ]
                    )

        hourSelected =
            \value -> value == (padTimePart timestamp.hour)

        minuteSelected =
            \value -> value == (padTimePart timestamp.minute)

        meridiemSelected =
            \value -> value == timestamp.meridiem
    in
        span []
            [ labelText
            , select
                hour
                [ option [ value "01", selected (hourSelected "01") ] [ text "1" ]
                , option [ value "02", selected (hourSelected "02") ] [ text "2" ]
                , option [ value "03", selected (hourSelected "03") ] [ text "3" ]
                , option [ value "04", selected (hourSelected "04") ] [ text "4" ]
                , option [ value "05", selected (hourSelected "05") ] [ text "5" ]
                , option [ value "06", selected (hourSelected "06") ] [ text "6" ]
                , option [ value "07", selected (hourSelected "07") ] [ text "7" ]
                , option [ value "08", selected (hourSelected "08") ] [ text "8" ]
                , option [ value "09", selected (hourSelected "09") ] [ text "9" ]
                , option [ value "10", selected (hourSelected "10") ] [ text "10" ]
                , option [ value "11", selected (hourSelected "11") ] [ text "11" ]
                , option [ value "12", selected (hourSelected "12") ] [ text "12" ]
                ]
            , select
                minute
                [ option [ value "00", selected (minuteSelected "00") ] [ text "00" ]
                , option [ value "30", selected (minuteSelected "30") ] [ text "30" ]
                ]
            , select
                meridiem
                [ option [ value "AM", selected (meridiemSelected "AM") ] [ text "AM" ]
                , option [ value "PM", selected (meridiemSelected "PM") ] [ text "PM" ]
                ]
            ]


loadingSpinner : Model -> Html Msg
loadingSpinner model =
    if model.loading then
        div [ class "loader" ] []
    else
        div [] []


myEvents : Model -> Html Msg
myEvents model =
    div [] <|
        let
            events =
                model.events
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


eventRow : Event -> Html Msg
eventRow event =
    tr [] [ td [] [ text event.name ], td [] [ text event.startTime ] ]


errorRow : Error -> Html Msg
errorRow error =
    tr [] [ td [] [ text error.title ] ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Name name ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            Just { ev | name = name }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent }, Cmd.none )

        Day day ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentTS =
                                    ev.startTimestamp

                                updatedTS =
                                    { currentTS | ymd = day }
                            in
                                Just { ev | startTimestamp = updatedTS }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent }, Cmd.none )

        Hour borderTime hour ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentTS =
                                    case borderTime of
                                        StartTime ->
                                            ev.startTimestamp

                                        EndTime ->
                                            ev.endTimestamp

                                updatedTS =
                                    let
                                        updatedHour =
                                            case String.toInt hour of
                                                Ok hr ->
                                                    hr

                                                Err err ->
                                                    currentTS.hour
                                    in
                                        { currentTS | hour = updatedHour }
                            in
                                case borderTime of
                                    StartTime ->
                                        Just { ev | startTimestamp = updatedTS }

                                    EndTime ->
                                        Just { ev | endTimestamp = updatedTS }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent }, Cmd.none )

        Minute borderTime minute ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentTS =
                                    case borderTime of
                                        StartTime ->
                                            ev.startTimestamp

                                        EndTime ->
                                            ev.endTimestamp

                                updatedTS =
                                    let
                                        updatedMinute =
                                            case String.toInt minute of
                                                Ok min ->
                                                    min

                                                Err err ->
                                                    currentTS.minute
                                    in
                                        { currentTS | minute = updatedMinute }
                            in
                                case borderTime of
                                    StartTime ->
                                        Just { ev | startTimestamp = updatedTS }

                                    EndTime ->
                                        Just { ev | endTimestamp = updatedTS }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent }, Cmd.none )

        Meridiem borderTime meridiem ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentTS =
                                    case borderTime of
                                        StartTime ->
                                            ev.startTimestamp

                                        EndTime ->
                                            ev.endTimestamp

                                updatedTS =
                                    { currentTS | meridiem = meridiem }
                            in
                                case borderTime of
                                    StartTime ->
                                        Just { ev | startTimestamp = updatedTS }

                                    EndTime ->
                                        Just { ev | endTimestamp = updatedTS }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent }, Cmd.none )

        SubmitEvent ->
            ( { model | loading = True }, Http.send CreateEventResult (createEvent model) )

        FetchEventsResult (Ok apiResult) ->
            ( { model | loading = False, apiResult = apiResult, events = apiResult.events }, Cmd.none )

        FetchEventsResult (Err err) ->
            ( handleAPIError model err, Cmd.none )

        CreateEventResult (Ok apiResult) ->
            ( { model | loading = False, apiResult = apiResult, event = apiResult.event }, Cmd.none )

        CreateEventResult (Err err) ->
            ( handleAPIError model err, Cmd.none )


eventsURL : Model -> String
eventsURL model =
    model.rootURL ++ "/api/events?slug=" ++ model.slug


handleAPIError : Model -> Http.Error -> Model
handleAPIError model err =
    let
        notLoadingModel =
            { model | loading = False }
    in
        case err of
            Http.BadStatus response ->
                let
                    decodeResult =
                        decodeString errorsDecoder response.body
                in
                    case decodeResult of
                        Ok apiResult ->
                            { notLoadingModel | apiResult = apiResult }

                        Err _ ->
                            { notLoadingModel | apiResult = { defaultAPIResult | errors = [ Error <| "Response failed: " ++ response.status.message ] } }

            Http.BadPayload message response ->
                { notLoadingModel
                    | apiResult =
                        { defaultAPIResult | errors = [ Error "Unexpected response from server" ] }
                }

            Http.BadUrl url ->
                { notLoadingModel
                    | apiResult =
                        { defaultAPIResult | errors = [ Error <| "Invalid URL: " ++ url ] }
                }

            Http.Timeout ->
                { notLoadingModel
                    | apiResult =
                        { defaultAPIResult | errors = [ Error <| "Request timed out" ] }
                }

            Http.NetworkError ->
                { notLoadingModel
                    | apiResult =
                        { defaultAPIResult | errors = [ Error <| "Network Error" ] }
                }


createEvent : Model -> Http.Request APIResult
createEvent model =
    Http.post (eventsURL model)
        (jsonBody <| encodeEvent model)
        (oneOf [ dataEventDecoder, errorsDecoder ])


encodeEvent : Model -> Value
encodeEvent model =
    case model.event of
        Nothing ->
            object []

        Just event ->
            let
                { id, name, startTimestamp, endTimestamp } =
                    event
            in
                object
                    [ ( "data"
                      , object
                            [ ( "event"
                              , object
                                    [ ( "name", JE.string name )
                                    , ( "start_time", JE.string <| serializeTimestamp startTimestamp )
                                    , ( "end_time", JE.string <| serializeTimestamp endTimestamp )
                                    , ( "author_id", JE.int <| model.authorID )
                                    ]
                              )
                            ]
                      )
                    ]


getEvents : Model -> Http.Request APIResult
getEvents model =
    Http.get ((eventsURL model) ++ "&author_nb_id=" ++ (toString model.authorID))
        (oneOf [ errorsDecoder, dataEventsDecoder ])


dataEventsDecoder =
    apiResultEvents <|
        field "data" <|
            list <|
                eventDecoder


dataEventDecoder =
    apiResultEvent <|
        field "data" <|
            eventDecoder


errorsDecoder =
    apiResultErrors <|
        field "errors" <|
            list <|
                Json.Decode.map Error (field "title" string)


eventDecoder =
    field "event" <|
        Json.Decode.map5 Event eventID eventName startTime decodeStartTimestamp decodeEndTimestamp


decodeStartTimestamp =
    succeed defaultStartTimestamp


decodeEndTimestamp =
    succeed defaultEndTimestamp


eventID =
    field "id" int


eventName =
    field "name" string


startTime =
    field "start_time" string


apiResultEvent : Json.Decode.Decoder Event -> Json.Decode.Decoder APIResult
apiResultEvent event =
    Json.Decode.map (\ev -> { errors = [], events = [], event = Just ev }) event


apiResultEvents : Json.Decode.Decoder (List Event) -> Json.Decode.Decoder APIResult
apiResultEvents events =
    Json.Decode.map (\evs -> { errors = [], events = evs, event = Nothing }) events


apiResultErrors : Json.Decode.Decoder (List Error) -> Json.Decode.Decoder APIResult
apiResultErrors errors =
    Json.Decode.map (\errs -> { errors = errs, events = [], event = Nothing }) errors
