module Views exposing (..)

import Html exposing (Html, div, button, text, input, label, h2, table, tr, td, select, option, span, ul, li)
import Html.Attributes exposing (class, type_, value, step, id, selected, style, for, disabled, placeholder)
import Html.Events exposing (onClick, onInput)
import Date exposing (Date)
import Result exposing (Result, andThen)
import Types exposing (..)


mainView : Model -> Html Msg
mainView model =
    div
        [ class "nb-integration-container" ]
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


submitButtonClass : Model -> String
submitButtonClass model =
    if invalidInput model then
        "create-event-button create-event-button-disabled"
    else
        "create-event-button"


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


lessThan : ( Date, Date ) -> Bool
lessThan ( d1, d2 ) =
    Date.toTime d1 < Date.toTime d2


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
