module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2, table, tr, td, select, option, span, ul, li)
import Html.Attributes exposing (class, type_, value, step, id, selected, style, for, disabled, placeholder)
import Html.Events exposing (onClick, onInput)
import Http exposing (jsonBody)
import Json.Decode exposing (field, dict, list, string, array, int, oneOf, decodeString, succeed, nullable)
import Json.Encode as JE exposing (Value, encode, object)
import String exposing (join)
import Dict exposing (Dict)
import Date exposing (Date)
import Result exposing (Result, andThen)


type Msg
    = SubmitEvent
    | FetchEventsResult (Result Http.Error APIResult)
    | CreateEventResult (Result Http.Error APIResult)
    | EventName String
    | EventIntro String
    | EventVenueName String
    | EventVenueAddress1 String
    | EventVenueCity String
    | EventVenueState String
    | ContactName String
    | ContactEmail String
    | Day String
    | Hour BorderTime String
    | Minute BorderTime String
    | Meridiem BorderTime String


type alias Event =
    { id : Int
    , intro : Maybe String
    , contact : Contact
    , name : Maybe String
    , startTimestamp : EditingTimestamp
    , endTimestamp : EditingTimestamp
    , venue : Venue
    }


defaultEvent : Event
defaultEvent =
    { id = 0
    , intro = Nothing
    , contact = { email = Nothing, name = Nothing }
    , name = Nothing
    , startTimestamp = defaultStartTimestamp
    , endTimestamp = defaultEndTimestamp
    , venue = defaultVenue
    }


type alias Venue =
    { name : Maybe String
    , address : Maybe Address
    }


defaultVenue : Venue
defaultVenue =
    { name = Nothing
    , address = Nothing
    }


type alias Address =
    { address1 : Maybe String
    , city : Maybe String
    , state : Maybe String
    }


defaultAddress : Address
defaultAddress =
    { address1 = Nothing
    , city = Nothing
    , state = Nothing
    }


type alias Contact =
    { name : Maybe String
    , email : Maybe String
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


type alias ShowValidationErrors =
    { showEventNameErrors : Bool
    , showContactNameErrors : Bool
    , showContactEmailErrors : Bool
    , showDateErrors : Bool
    , showStreetAddressErrors : Bool
    , showCityErrors : Bool
    , showStateErrors : Bool
    }


defaultShowValidationErrors : ShowValidationErrors
defaultShowValidationErrors =
    { showEventNameErrors = False
    , showContactNameErrors = False
    , showContactEmailErrors = False
    , showDateErrors = False
    , showStreetAddressErrors = False
    , showCityErrors = False
    , showStateErrors = False
    }


type alias Model =
    { apiResult : APIResult
    , authorID : Int
    , authorEmail : String
    , event : Maybe Event
    , events : List Event
    , rootURL : String
    , slug : String
    , loading : Bool
    , validationErrors : ShowValidationErrors
    }


defaultModel : Flags -> Model
defaultModel flags =
    { apiResult = { errors = [], events = [], event = Nothing }
    , authorID = flags.authorID
    , authorEmail = flags.authorEmail
    , event = Just defaultEvent
    , events = []
    , rootURL = flags.rootURL
    , slug = flags.slug
    , loading = True
    , validationErrors = defaultShowValidationErrors
    }


type alias Flags =
    { authorID : Int, authorEmail : String, access_token : String, rootURL : String, slug : String }


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
            defaultModel flags
    in
        ( model, Http.send FetchEventsResult (getEvents model) )


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div [ class "nb-integration-container" ]
        [ div [ class "event-form " ]
            [ ul [ class "flex-outer" ]
                [ li [] <| List.concat [ selectDay, [ span [ class <| validationClass False ] [] ] ]
                , li []
                    [ label [ for "start-time" ] [ text "Start Time" ]
                    , selectTime StartTime (currentTimestamp model StartTime)
                    , span [ class <| validationClass False ] []
                    ]
                , li [ class "section-end" ]
                    [ label [ for "end-time" ] [ text "End Time" ]
                    , selectTime EndTime (currentTimestamp model EndTime)
                    , span
                        [ class <| validationClass model.validationErrors.showDateErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showDateErrors ) ]
                        ]
                        [ text "End Time must be after Start Time" ]
                    ]
                , li []
                    [ label [ for "contact-name" ] [ text "Contact Name" ]
                    , input [ id "contact-name", type_ "contact-name", placeholder "(Required)", onInput ContactName ] []
                    , span
                        [ class <| validationClass model.validationErrors.showContactNameErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showContactNameErrors ) ]
                        ]
                        [ text "Contact name must be present" ]
                    ]
                , li [ class "section-end" ]
                    [ label [ for "contact-email" ] [ text "Contact Email" ]
                    , input [ id "contact-email", type_ "contact-email", placeholder "(Required)", onInput ContactEmail ] []
                    , span
                        [ class <| validationClass model.validationErrors.showContactEmailErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showContactEmailErrors ) ]
                        ]
                        [ text "Contact email must be present" ]
                    ]
                , li []
                    [ label [ for "event-name" ] [ text "Event Name" ]
                    , input [ id "event-name", type_ "event-name", placeholder "(Required)", onInput EventName ] []
                    , span
                        [ class <| validationClass model.validationErrors.showEventNameErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showEventNameErrors ) ]
                        ]
                        [ text "Event name must be present" ]
                    ]
                , li [ class "section-end" ]
                    [ label [ for "event-intro" ] [ text "Event Intro" ]
                    , input [ id "event-intro", type_ "event-intro", onInput EventIntro ] []
                    , span [ class <| validationClass False ] []
                    ]
                , li []
                    [ label [ for "event-venue-name" ] [ text "Venue Name" ]
                    , input [ id "event-venue-name", type_ "event-venue-name", onInput EventVenueName ] []
                    , span [ class <| validationClass False ] []
                    ]
                , li []
                    [ label [ for "event-venue-address1" ] [ text "Street Address" ]
                    , input [ id "event-venue-address1", type_ "event-venue-address1", placeholder "(Required)", onInput EventVenueAddress1 ] []
                    , span
                        [ class <| validationClass model.validationErrors.showStreetAddressErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showStreetAddressErrors ) ]
                        ]
                        [ text "Street address must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-city" ] [ text "City" ]
                    , input [ id "event-venue-city", type_ "event-venue-city", placeholder "(Required)", onInput EventVenueCity ] []
                    , span
                        [ class <| validationClass model.validationErrors.showCityErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showCityErrors ) ]
                        ]
                        [ text "City must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-state" ] [ text "State" ]
                    , input [ id "event-venue-state", type_ "event-venue-state", placeholder "(Required)", onInput EventVenueState ] []
                    , span
                        [ class <| validationClass model.validationErrors.showStateErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showStateErrors ) ]
                        ]
                        [ text "State must be present" ]
                    ]
                , li [ class <| submitButtonClass model ]
                    [ label [] []
                    , button [ onClick SubmitEvent ] [ text "Submit Event" ]
                    , span [ class <| validationClass False ] []
                    ]
                ]
            ]
        , div [ id "display-event", style [ ( "display", "none" ) ] ]
            [ div [] [ text <| "Start Time: " ++ formatTimestamp model.event StartTime ]
            , div [] [ text <| "End Time: " ++ formatTimestamp model.event EndTime ]
            , div []
                [ text <|
                    "Start Time < End Time: "
                        ++ (if datesOk model then
                                "true"
                            else
                                "false"
                           )
                ]
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


selectDay : List (Html Msg)
selectDay =
    [ label [ for "date" ] [ text "Date" ]
    , select
        [ onInput Day ]
        [ option [ value "2018-09-24" ] [ text "Mon 9/24" ]
        , option [ value "2018-09-25" ] [ text "Tue 9/25" ]
        , option [ value "2018-09-26" ] [ text "Wed 9/26" ]
        , option [ value "2018-09-27" ] [ text "Thu 9/27" ]
        , option [ value "2018-09-28" ] [ text "Fri 9/28" ]
        , option [ value "2018-09-29" ] [ text "Sat 9/29" ]
        , option [ value "2018-09-30" ] [ text "Sun 9/30" ]
        ]
    ]


selectTime : BorderTime -> EditingTimestamp -> Html Msg
selectTime borderTime timestamp =
    let
        ( hour, minute, meridiem ) =
            case borderTime of
                StartTime ->
                    ( [ id "startHour", onInput (Hour StartTime) ]
                    , [ id "startMinute", onInput (Minute StartTime) ]
                    , [ id "startMeridiem", onInput (Meridiem StartTime) ]
                    )

                EndTime ->
                    ( [ id "endHour", onInput (Hour EndTime) ]
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
        ul [ class "flex-inner" ]
            [ select
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
    tr [] [ td [] [ text <| Maybe.withDefault "" event.name ] ]


errorRow : Error -> Html Msg
errorRow error =
    tr [] [ td [] [ text error.title ] ]


showDateError : ShowValidationErrors -> Bool -> ShowValidationErrors
showDateError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showDateErrors = True }
    else
        { validationErrors | showDateErrors = False }


showEventNameError : ShowValidationErrors -> Bool -> ShowValidationErrors
showEventNameError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showEventNameErrors = True }
    else
        { validationErrors | showEventNameErrors = False }


showContactNameError : ShowValidationErrors -> Bool -> ShowValidationErrors
showContactNameError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showContactNameErrors = True }
    else
        { validationErrors | showContactNameErrors = False }


showContactEmailError : ShowValidationErrors -> Bool -> ShowValidationErrors
showContactEmailError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showContactEmailErrors = True }
    else
        { validationErrors | showContactEmailErrors = False }


showStreetAddressError : ShowValidationErrors -> Bool -> ShowValidationErrors
showStreetAddressError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showStreetAddressErrors = True }
    else
        { validationErrors | showStreetAddressErrors = False }


showCityError : ShowValidationErrors -> Bool -> ShowValidationErrors
showCityError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showCityErrors = True }
    else
        { validationErrors | showCityErrors = False }


showStateError : ShowValidationErrors -> Bool -> ShowValidationErrors
showStateError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showStateErrors = True }
    else
        { validationErrors | showStateErrors = False }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EventName name ->
            let
                updatedErrors =
                    showEventNameError model.validationErrors (String.length name == 0)

                updatedEvent =
                    case model.event of
                        Just ev ->
                            Just { ev | name = Just name }

                        Nothing ->
                            Just { defaultEvent | name = Just name }
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        EventIntro intro ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            Just { ev | intro = Just intro }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent }, Cmd.none )

        EventVenueAddress1 address1 ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentVenue =
                                    ev.venue

                                currentAddress =
                                    currentVenue.address

                                updatedAddress =
                                    case currentAddress of
                                        Just address ->
                                            Just { address | address1 = Just address1 }

                                        Nothing ->
                                            Just { defaultAddress | address1 = Just address1 }

                                updatedVenue =
                                    { currentVenue | address = updatedAddress }
                            in
                                Just { ev | venue = updatedVenue }

                        Nothing ->
                            Nothing

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showStreetAddressError model.validationErrors (not <| streetAddressPresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueCity city ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentVenue =
                                    ev.venue

                                currentAddress =
                                    currentVenue.address

                                updatedAddress =
                                    case currentAddress of
                                        Just address ->
                                            Just { address | city = Just city }

                                        Nothing ->
                                            Just { defaultAddress | city = Just city }

                                updatedVenue =
                                    { currentVenue | address = updatedAddress }
                            in
                                Just { ev | venue = updatedVenue }

                        Nothing ->
                            Nothing

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showCityError model.validationErrors (not <| cityPresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueState state ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentVenue =
                                    ev.venue

                                currentAddress =
                                    currentVenue.address

                                updatedAddress =
                                    case currentAddress of
                                        Just address ->
                                            Just { address | state = Just state }

                                        Nothing ->
                                            Just { defaultAddress | state = Just state }

                                updatedVenue =
                                    { currentVenue | address = updatedAddress }
                            in
                                Just { ev | venue = updatedVenue }

                        Nothing ->
                            Nothing

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showStateError model.validationErrors (not <| statePresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueName name ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentVenue =
                                    ev.venue

                                updatedVenue =
                                    { currentVenue | name = Just name }
                            in
                                Just { ev | venue = updatedVenue }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent }, Cmd.none )

        ContactEmail email ->
            let
                updatedErrors =
                    showContactEmailError model.validationErrors (String.length email == 0)

                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentContact =
                                    ev.contact

                                updatedContact =
                                    { currentContact | email = Just email }
                            in
                                Just { ev | contact = updatedContact }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        ContactName name ->
            let
                updatedErrors =
                    showContactNameError model.validationErrors (String.length name == 0)

                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentContact =
                                    ev.contact

                                updatedContact =
                                    { currentContact | name = Just name }
                            in
                                Just { ev | contact = updatedContact }

                        Nothing ->
                            Nothing
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        Day day ->
            let
                updatedEvent =
                    case model.event of
                        Just ev ->
                            let
                                currentStartTS =
                                    ev.startTimestamp

                                currentEndTS =
                                    ev.endTimestamp

                                updatedStartTS =
                                    { currentStartTS | ymd = day }

                                updatedEndTS =
                                    { currentEndTS | ymd = day }
                            in
                                Just
                                    { ev
                                        | startTimestamp = updatedStartTS
                                        , endTimestamp = updatedEndTS
                                    }

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

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

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

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

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

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        SubmitEvent ->
            if invalidInput model then
                ( { model | validationErrors = showValidationErrors model }
                , Cmd.none
                )
            else
                ( { model
                    | validationErrors = showValidationErrors model
                    , loading = True
                  }
                , Http.send CreateEventResult (createEvent model)
                )

        FetchEventsResult (Ok apiResult) ->
            ( { model | loading = False, apiResult = apiResult, events = apiResult.events }, Cmd.none )

        FetchEventsResult (Err err) ->
            ( handleAPIError model err, Cmd.none )

        CreateEventResult (Ok apiResult) ->
            ( { model
                | loading = False
                , apiResult = apiResult
                , event = apiResult.event
                , events =
                    case apiResult.event of
                        Just ev ->
                            ev :: model.events

                        Nothing ->
                            model.events
              }
            , Cmd.none
            )

        CreateEventResult (Err err) ->
            ( handleAPIError model err, Cmd.none )


showValidationErrors : Model -> ShowValidationErrors
showValidationErrors model =
    { showEventNameErrors = not <| eventNamePresent model
    , showContactNameErrors = not <| contactNamePresent model
    , showContactEmailErrors = not <| contactEmailPresent model
    , showDateErrors = not <| datesOk model
    , showStreetAddressErrors = not <| streetAddressPresent model
    , showCityErrors = not <| cityPresent model
    , showStateErrors = not <| statePresent model
    }


eventNamePresent : Model -> Bool
eventNamePresent model =
    (Maybe.andThen .name model.event |> Maybe.withDefault "" |> String.length) > 0


eventAddress : Model -> Maybe Address
eventAddress model =
    Maybe.map .venue model.event |> Maybe.andThen .address


streetAddressPresent : Model -> Bool
streetAddressPresent model =
    String.length
        (Maybe.withDefault "" (eventAddress model |> Maybe.andThen .address1))
        > 0


cityPresent : Model -> Bool
cityPresent model =
    String.length
        (Maybe.withDefault "" (eventAddress model |> Maybe.andThen .city))
        > 0


statePresent : Model -> Bool
statePresent model =
    String.length
        (Maybe.withDefault "" (eventAddress model |> Maybe.andThen .state))
        > 0


contactNamePresent : Model -> Bool
contactNamePresent model =
    let
        cName =
            case model.event of
                Just ev ->
                    Maybe.withDefault "" ev.contact.name

                Nothing ->
                    ""
    in
        String.length cName > 0


contactEmailPresent : Model -> Bool
contactEmailPresent model =
    let
        val =
            case model.event of
                Just ev ->
                    Maybe.withDefault "" ev.contact.email

                Nothing ->
                    ""
    in
        String.length val > 0


asDate : EditingTimestamp -> Result String Date
asDate et =
    Date.fromString (serializeTimestamp et)


secondDate : EditingTimestamp -> Date -> Result String ( Date, Date )
secondDate et firstDate =
    case asDate et of
        Ok date ->
            Ok ( firstDate, date )

        Err err ->
            Err err


lessThan : ( Date, Date ) -> Bool
lessThan ( d1, d2 ) =
    Date.toTime d1 < Date.toTime d2


submitButtonClass : Model -> String
submitButtonClass model =
    if invalidInput model then
        "create-event-button create-event-button-disabled"
    else
        "create-event-button"


invalidInput : Model -> Bool
invalidInput model =
    not <|
        List.all identity
            [ datesOk model
            , contactNamePresent model
            , contactEmailPresent model
            , eventNamePresent model
            , streetAddressPresent model
            , cityPresent model
            , statePresent model
            ]


displayEventNameErrors : Model -> Bool
displayEventNameErrors model =
    model.validationErrors.showEventNameErrors && invalidInput model


validationClass : Bool -> String
validationClass showErrors =
    if showErrors then
        "validation validation-errors"
    else
        "validation"


validationVisibility : Bool -> String
validationVisibility showErrors =
    if showErrors then
        "visible"
    else
        "hidden"


datesOk : Model -> Bool
datesOk model =
    case model.event of
        Just ev ->
            let
                dates =
                    asDate ev.startTimestamp
                        |> andThen (secondDate ev.endTimestamp)
            in
                case dates of
                    Ok ( sd, ed ) ->
                        lessThan ( sd, ed )

                    Err _ ->
                        False

        Nothing ->
            False


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
                { id, name, intro, contact, startTimestamp, endTimestamp, venue } =
                    event
            in
                object
                    [ ( "data"
                      , object
                            [ ( "event"
                              , object
                                    [ ( "name", encodeMaybeString name )
                                    , ( "intro", encodeMaybeString intro )
                                    , ( "contact", encodeContact contact )
                                    , ( "start_time", JE.string <| serializeTimestamp startTimestamp )
                                    , ( "end_time", JE.string <| serializeTimestamp endTimestamp )
                                    , ( "author_id", JE.int <| model.authorID )
                                    , ( "author_email", JE.string <| model.authorEmail )
                                    , ( "venue", encodeVenue venue )
                                    ]
                              )
                            ]
                      )
                    ]


encodeVenue : Venue -> Value
encodeVenue venue =
    let
        name =
            case venue.name of
                Just n ->
                    ( "name", JE.string n )

                Nothing ->
                    ( "name", JE.null )

        address =
            encodeAddress venue.address
    in
        object [ name, address ]


encodeAddress : Maybe Address -> ( String, Value )
encodeAddress address =
    let
        encodedAddress =
            case address of
                Just a ->
                    JE.object
                        [ ( "address1", encodeMaybeString a.address1 )
                        , ( "city", encodeMaybeString a.city )
                        , ( "state", encodeMaybeString a.state )
                        ]

                Nothing ->
                    JE.null
    in
        ( "address", encodedAddress )


encodeContact : Contact -> Value
encodeContact contact =
    let
        name =
            case contact.name of
                Just n ->
                    ( "name", JE.string n )

                Nothing ->
                    ( "name", JE.null )

        email =
            case contact.email of
                Just e ->
                    ( "email", JE.string e )

                Nothing ->
                    ( "email", JE.null )
    in
        object [ name, email ]


encodeMaybeString : Maybe String -> Value
encodeMaybeString mString =
    case mString of
        Just str ->
            JE.string str

        Nothing ->
            JE.null


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
        Json.Decode.map7 Event
            eventID
            eventIntro
            contact
            eventName
            decodeStartTimestamp
            decodeEndTimestamp
            decodeVenue


decodeVenue =
    field "venue" <| Json.Decode.map2 Venue decodeVenueName decodeVenueAddress


decodeVenueName =
    Json.Decode.maybe <| field "name" string


decodeVenueAddress =
    Json.Decode.maybe <|
        field "address" <|
            Json.Decode.map3 Address
                (Json.Decode.maybe (field "address1" string))
                (Json.Decode.maybe (field "city" string))
                (Json.Decode.maybe (field "state" string))


decodeStartTimestamp =
    succeed defaultStartTimestamp


decodeEndTimestamp =
    succeed defaultEndTimestamp


eventID =
    field "id" int


eventName =
    field "name" (nullable string)


eventIntro =
    field "intro" (nullable string)


contact =
    field "contact" <|
        Json.Decode.map2 Contact contactName contactEmail


contactName =
    field "name" (nullable string)


contactEmail =
    field "email" (nullable string)


apiResultEvent : Json.Decode.Decoder Event -> Json.Decode.Decoder APIResult
apiResultEvent event =
    Json.Decode.map (\ev -> { errors = [], events = [ ev ], event = Just ev }) event


apiResultEvents : Json.Decode.Decoder (List Event) -> Json.Decode.Decoder APIResult
apiResultEvents events =
    Json.Decode.map (\evs -> { errors = [], events = evs, event = Nothing }) events


apiResultErrors : Json.Decode.Decoder (List Error) -> Json.Decode.Decoder APIResult
apiResultErrors errors =
    Json.Decode.map (\errs -> { errors = errs, events = [], event = Nothing }) errors
