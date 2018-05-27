module Main exposing (..)

import Html exposing (Html, programWithFlags, div, button, text, input, label, h2, table, tr, td, select, option, span, ul, li)
import Html.Attributes exposing (class, type_, value, step, id, selected, style, for, disabled, placeholder)
import Html.Events exposing (onClick, onInput)
import Http exposing (jsonBody)
import Json.Decode as JD exposing (field, dict, list, string, array, int, oneOf, decodeString, succeed, nullable)
import Json.Encode as JE exposing (Value, encode, object)
import String exposing (join)
import Dict exposing (Dict)
import Date exposing (Date)
import Result exposing (Result, andThen)
import Types exposing (..)


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
                , li []
                    [ label [ for "end-time" ] [ text "End Time" ]
                    , selectTime EndTime (currentTimestamp model EndTime)
                    , span
                        [ class <| validationClass model.validationErrors.showDateErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showDateErrors ) ]
                        ]
                        [ text "End Time must be after Start Time" ]
                    ]
                , li [ class "section-start" ]
                    [ label [ for "contact-name" ] [ text "Contact Name" ]
                    , input [ id "contact-name", type_ "contact-name", placeholder "Required", onInput ContactName ] []
                    , span
                        [ class <| validationClass model.validationErrors.showContactNameErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showContactNameErrors ) ]
                        ]
                        [ text "Contact name must be present" ]
                    ]
                , li []
                    [ label [ for "contact-email" ] [ text "Contact Email" ]
                    , input [ id "contact-email", type_ "contact-email", placeholder "Required", onInput ContactEmail ] []
                    , span
                        [ class <| validationClass model.validationErrors.showContactEmailErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showContactEmailErrors ) ]
                        ]
                        [ text "Contact email must be present" ]
                    ]
                , li [ class "section-start" ]
                    [ label [ for "event-name" ] [ text "Event Name" ]
                    , input [ id "event-name", type_ "event-name", placeholder "Required", onInput EventName ] []
                    , span
                        [ class <| validationClass model.validationErrors.showEventNameErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showEventNameErrors ) ]
                        ]
                        [ text "Event name must be present" ]
                    ]
                , li []
                    [ label [ for "event-intro" ] [ text "Event Intro" ]
                    , input [ id "event-intro", type_ "event-intro", onInput EventIntro ] []
                    , span [ class <| validationClass False ] []
                    ]
                , li [ class "section-start" ]
                    [ label [ for "event-venue-name" ] [ text "Venue Name" ]
                    , input [ id "event-venue-name", type_ "event-venue-name", placeholder "Required", onInput EventVenueName ] []
                    , span
                        [ class <| validationClass model.validationErrors.showVenueNameErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showVenueNameErrors ) ]
                        ]
                        [ text "Venue name must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-address1" ] [ text "Street Address" ]
                    , input [ id "event-venue-address1", type_ "event-venue-address1", placeholder "Required", onInput EventVenueAddress1 ] []
                    , span
                        [ class <| validationClass model.validationErrors.showStreetAddressErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showStreetAddressErrors ) ]
                        ]
                        [ text "Street address must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-city" ] [ text "City" ]
                    , input [ id "event-venue-city", type_ "event-venue-city", placeholder "Required", onInput EventVenueCity ] []
                    , span
                        [ class <| validationClass model.validationErrors.showCityErrors
                        , style [ ( "visibility", validationVisibility model.validationErrors.showCityErrors ) ]
                        ]
                        [ text "City must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-state" ] [ text "State" ]
                    , input [ id "event-venue-state", type_ "event-venue-state", placeholder "Required", onInput EventVenueState ] []
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
    case borderTime of
        StartTime ->
            model.event.startTimestamp

        EndTime ->
            model.event.endTimestamp


padTimePart : Int -> String
padTimePart num =
    String.padLeft 2 '0' <| toString num


formatTimestamp : Event -> BorderTime -> String
formatTimestamp event borderTime =
    let
        timestamp =
            case borderTime of
                StartTime ->
                    event.startTimestamp

                EndTime ->
                    event.endTimestamp
    in
        serializeTimestamp timestamp


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
                case model.apiResult of
                    APIErrors errors ->
                        errors

                    _ ->
                        []
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


showVenueNameError : ShowValidationErrors -> Bool -> ShowValidationErrors
showVenueNameError validationErrors shouldShow =
    if shouldShow then
        { validationErrors | showVenueNameErrors = True }
    else
        { validationErrors | showVenueNameErrors = False }


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

                ev =
                    model.event

                updatedEvent =
                    { ev | name = name }
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        EventIntro intro ->
            let
                ev =
                    model.event

                updatedEvent =
                    { ev | intro = intro }
            in
                ( { model | event = updatedEvent }, Cmd.none )

        EventVenueAddress1 address1 ->
            let
                ev =
                    model.event

                updatedEvent =
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
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showStreetAddressError model.validationErrors (not <| streetAddressPresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueCity city ->
            let
                ev =
                    model.event

                updatedEvent =
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
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showCityError model.validationErrors (not <| cityPresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueState state ->
            let
                ev =
                    model.event

                updatedEvent =
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
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showStateError model.validationErrors (not <| statePresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        EventVenueName name ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentVenue =
                            ev.venue

                        updatedVenue =
                            { currentVenue | name = Just name }
                    in
                        { ev | venue = updatedVenue }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showVenueNameError model.validationErrors (not <| venueNamePresent updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        ContactEmail email ->
            let
                updatedErrors =
                    showContactEmailError model.validationErrors (String.length email == 0)

                ev =
                    model.event

                updatedEvent =
                    let
                        currentContact =
                            ev.contact

                        updatedContact =
                            { currentContact | email = Just email }
                    in
                        { ev | contact = updatedContact }
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        ContactName name ->
            let
                updatedErrors =
                    showContactNameError model.validationErrors (String.length name == 0)

                ev =
                    model.event

                updatedEvent =
                    let
                        currentContact =
                            ev.contact

                        updatedContact =
                            { currentContact | name = Just name }
                    in
                        { ev | contact = updatedContact }
            in
                ( { model | event = updatedEvent, validationErrors = updatedErrors }, Cmd.none )

        Day day ->
            let
                ev =
                    model.event

                updatedEvent =
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
                        { ev
                            | startTimestamp = updatedStartTS
                            , endTimestamp = updatedEndTS
                        }
            in
                ( { model | event = updatedEvent }, Cmd.none )

        Hour borderTime hour ->
            let
                ev =
                    model.event

                updatedEvent =
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
                                { ev | startTimestamp = updatedTS }

                            EndTime ->
                                { ev | endTimestamp = updatedTS }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        Minute borderTime minute ->
            let
                ev =
                    model.event

                updatedEvent =
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
                                { ev | startTimestamp = updatedTS }

                            EndTime ->
                                { ev | endTimestamp = updatedTS }

                updatedModel =
                    { model | event = updatedEvent }

                updatedErrors =
                    showDateError model.validationErrors (not <| datesOk updatedModel)
            in
                ( { updatedModel | validationErrors = updatedErrors }, Cmd.none )

        Meridiem borderTime meridiem ->
            let
                ev =
                    model.event

                updatedEvent =
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
                                { ev | startTimestamp = updatedTS }

                            EndTime ->
                                { ev | endTimestamp = updatedTS }

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
            let
                modelWithResult =
                    { model | loading = False, apiResult = apiResult }
            in
                case apiResult of
                    APIEvents events ->
                        ( { modelWithResult | events = events }, Cmd.none )

                    _ ->
                        ( modelWithResult, Cmd.none )

        FetchEventsResult (Err err) ->
            ( handleAPIError model err, Cmd.none )

        CreateEventResult (Ok apiResult) ->
            let
                modelWithResult =
                    { model | loading = False, apiResult = apiResult }
            in
                case apiResult of
                    APIEvent event ->
                        ( { modelWithResult | event = event, events = event :: model.events }, Cmd.none )

                    _ ->
                        ( modelWithResult, Cmd.none )

        CreateEventResult (Err err) ->
            ( handleAPIError model err, Cmd.none )


showValidationErrors : Model -> ShowValidationErrors
showValidationErrors model =
    { showEventNameErrors = not <| eventNamePresent model
    , showContactNameErrors = not <| contactNamePresent model
    , showContactEmailErrors = not <| contactEmailPresent model
    , showDateErrors = not <| datesOk model
    , showVenueNameErrors = not <| venueNamePresent model
    , showStreetAddressErrors = not <| streetAddressPresent model
    , showCityErrors = not <| cityPresent model
    , showStateErrors = not <| statePresent model
    }


eventNamePresent : Model -> Bool
eventNamePresent model =
    String.length model.event.name > 0


eventVenueName : Model -> Maybe String
eventVenueName model =
    model.event.venue.name


eventAddress : Model -> Maybe Address
eventAddress model =
    model.event.venue.address


streetAddressPresent : Model -> Bool
streetAddressPresent model =
    String.length
        (Maybe.withDefault "" (eventAddress model |> Maybe.andThen .address1))
        > 0


venueNamePresent : Model -> Bool
venueNamePresent model =
    String.length (Maybe.withDefault "" <| eventVenueName model) > 0


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
    String.length (Maybe.withDefault "" model.event.contact.name) > 0


contactEmailPresent : Model -> Bool
contactEmailPresent model =
    String.length (Maybe.withDefault "" model.event.contact.email) > 0


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
            , venueNamePresent model
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
    let
        dates =
            andThen (secondDate model.event.endTimestamp) (asDate model.event.startTimestamp)
    in
        case dates of
            Ok ( sd, ed ) ->
                lessThan ( sd, ed )

            Err _ ->
                False


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
                            { notLoadingModel | apiResult = APIErrors [ Error <| "Response failed: " ++ response.status.message ] }

            Http.BadPayload message response ->
                { notLoadingModel | apiResult = APIErrors [ Error "Unexpected response from server" ] }

            Http.BadUrl url ->
                { notLoadingModel | apiResult = APIErrors [ Error <| "Invalid URL: " ++ url ] }

            Http.Timeout ->
                { notLoadingModel | apiResult = APIErrors [ Error <| "Request timed out" ] }

            Http.NetworkError ->
                { notLoadingModel | apiResult = APIErrors [ Error <| "Network Error" ] }


createEvent : Model -> Http.Request APIResult
createEvent model =
    Http.post (eventsURL model)
        (jsonBody <| encodeEvent model)
        (oneOf [ dataEventDecoder, errorsDecoder ])


encodeEvent : Model -> Value
encodeEvent model =
    let
        { id, name, intro, contact, startTimestamp, endTimestamp, venue } =
            model.event
    in
        object
            [ ( "data"
              , object
                    [ ( "event"
                      , object
                            [ ( "name", JE.string name )
                            , ( "intro"
                              , if String.length intro > 0 then
                                    JE.string intro
                                else
                                    JE.null
                              )
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
    JD.map APIEvents <|
        field "data" <|
            list <|
                eventDecoder


dataEventDecoder =
    JD.map APIEvent <|
        field "data" <|
            eventDecoder


errorsDecoder =
    JD.map APIErrors <|
        field "errors" <|
            list <|
                JD.map Error (field "title" string)


eventDecoder =
    field "event" <|
        JD.map7 Event
            eventID
            eventIntro
            contact
            eventName
            decodeStartTimestamp
            decodeEndTimestamp
            decodeVenue


decodeVenue =
    field "venue" <| JD.map2 Venue decodeVenueName decodeVenueAddress


decodeVenueName =
    JD.maybe <| field "name" string


decodeVenueAddress =
    JD.maybe <|
        field "address" <|
            JD.map3 Address
                (JD.maybe (field "address1" string))
                (JD.maybe (field "city" string))
                (JD.maybe (field "state" string))


decodeStartTimestamp =
    succeed defaultStartTimestamp


decodeEndTimestamp =
    succeed defaultEndTimestamp


eventID =
    field "id" int


eventName =
    field "name" (nullable string)
        |> JD.map (\m -> Maybe.withDefault "" m)


eventIntro =
    field "intro" (nullable string)
        |> JD.map (\m -> Maybe.withDefault "" m)


contact =
    field "contact" <|
        JD.map2 Contact contactName contactEmail


contactName =
    field "name" (nullable string)


contactEmail =
    field "email" (nullable string)
