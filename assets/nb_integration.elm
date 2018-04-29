module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2, table, tr, td, select, option, span)
import Html.Attributes exposing (class, type_, value, step, id)
import Html.Events exposing (onClick, onInput)
import Http exposing (jsonBody)
import Json.Decode exposing (field, dict, list, string, array, int, oneOf, decodeString)
import Json.Encode as JE exposing (Value, encode, object)
import String exposing (join)
import Dict exposing (Dict)


type Msg
    = SubmitEvent
    | FetchEventsResult (Result Http.Error APIResult)
    | CreateEventResult (Result Http.Error APIResult)
    | Name String


type alias Event =
    { id : Int, name : String }


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
            , event = Nothing
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
            , div [] [ label [] [ text "Start Date: ", selectDay ] ]
            , div [] [ label [] [ selectTime StartTime ] ]
            , div [] [ label [] [ selectTime EndTime ] ]
            , div [] [ label [] [ text "Capacity:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Venue:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Contact Name:", input [ type_ "text" ] [] ] ]
            , div [] [ label [] [ text "Contact Email:", input [ type_ "text" ] [] ] ]
            , div [] [ button [ onClick SubmitEvent ] [ text "Submit Event" ] ]
            ]
        , loadingSpinner model
        , div [ class "error-container" ] [ errorDisplay model ]
        , div [ class "event-list" ] [ myEvents model ]
        ]


selectDay : Html Msg
selectDay =
    span []
        [ span [] [ text "September" ]
        , select
            []
            [ option [ value "2018-09-03" ] [ text "3 Monday" ]
            , option [ value "2018-09-04" ] [ text "4 Tuesday" ]
            , option [ value "2018-09-05" ] [ text "5 Wednesday" ]
            , option [ value "2018-09-06" ] [ text "6 Thursday" ]
            , option [ value "2018-09-07" ] [ text "7 Friday" ]
            ]
        , span [] [ text "2018" ]
        ]


selectTime : BorderTime -> Html Msg
selectTime borderTime =
    let
        ( labelText, hour, minute, meridiem ) =
            case borderTime of
                StartTime ->
                    ( span [] [ text "Start Time" ]
                    , id "startHour"
                    , id "startMinute"
                    , id "startMeridiem"
                    )

                EndTime ->
                    ( span [] [ text "End Time" ]
                    , id "endHour"
                    , id "endMinute"
                    , id "endMeridiem"
                    )
    in
        span []
            [ labelText
            , select
                [ hour ]
                [ option [ value "01" ] [ text "01" ]
                , option [ value "02" ] [ text "02" ]
                , option [ value "03" ] [ text "03" ]
                , option [ value "04" ] [ text "04" ]
                , option [ value "05" ] [ text "05" ]
                , option [ value "06" ] [ text "06" ]
                , option [ value "07" ] [ text "07" ]
                , option [ value "08" ] [ text "08" ]
                , option [ value "09" ] [ text "09" ]
                , option [ value "10" ] [ text "10" ]
                , option [ value "11" ] [ text "11" ]
                , option [ value "12" ] [ text "12" ]
                ]
            , select
                [ minute ]
                [ option [ value "00" ] [ text "00" ]
                , option [ value "30" ] [ text "30" ]
                ]
            , select
                [ meridiem ]
                [ option [ value "AM" ] [ text "AM" ]
                , option [ value "PM" ] [ text "PM" ]
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
    tr [] [ td [] [ text event.name ] ]


errorRow : Error -> Html Msg
errorRow error =
    tr [] [ td [] [ text error.title ] ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Name name ->
            ( { model | event = Just (Event 0 name) }, Cmd.none )

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
        errorsDecoder


encodeEvent : Model -> Value
encodeEvent model =
    case model.event of
        Nothing ->
            object []

        Just event ->
            let
                { id, name } =
                    event
            in
                object
                    [ ( "data"
                      , object
                            [ ( "event"
                              , object [ ( "name", JE.string name ) ]
                              )
                            ]
                      )
                    ]


getEvents : Model -> Http.Request APIResult
getEvents model =
    Http.get ((eventsURL model) ++ "&author_nb_id=" ++ (toString model.authorID))
        (oneOf [ errorsDecoder, eventsDecoder ])


eventsDecoder =
    apiResultEvents <|
        field "data" <|
            list <|
                eventDecoder


errorsDecoder =
    apiResultErrors <|
        field "errors" <|
            list <|
                Json.Decode.map Error (field "title" string)


eventDecoder =
    field "event" <|
        Json.Decode.map2 Event eventID eventName


eventID =
    field "id" int


eventName =
    field "name" string


apiResultEvents : Json.Decode.Decoder (List Event) -> Json.Decode.Decoder APIResult
apiResultEvents events =
    Json.Decode.map (\evs -> { errors = [], events = evs, event = Nothing }) events


apiResultErrors : Json.Decode.Decoder (List Error) -> Json.Decode.Decoder APIResult
apiResultErrors errors =
    Json.Decode.map (\errs -> { errors = errs, events = [], event = Nothing }) errors
