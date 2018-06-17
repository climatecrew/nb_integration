module Views exposing (..)

import Html exposing (Html, div, button, text, input, label, h2, table, tr, td, select, option, span, ul, li)
import Html.Attributes exposing (class, type_, value, step, id, selected, style, for, disabled, placeholder)
import Html.Events exposing (onClick, onInput)
import Types exposing (..)
import EditingTimestamp exposing (EditingTimestamp, BorderTime, startTime, endTime)
import Utilities exposing (..)
import Validation exposing (..)


mainView : Model -> Html Msg
mainView model =
    div
        [ class "nb-integration-container" ]
        [ div [ class "event-form " ]
            [ ul [ class "flex-outer" ]
                [ li [] <| List.concat [ selectDay, [ emptyValidationView ] ]
                , li []
                    [ label [ for "start-time" ] [ text "Start Time" ]
                    , selectTime startTime (currentTimestamp model startTime)
                    , emptyValidationView
                    ]
                , li []
                    [ label [ for "end-time" ] [ text "End Time" ]
                    , selectTime endTime (currentTimestamp model endTime)
                    , dateErrorView model
                    ]
                , li [ class "section-start" ]
                    [ label [ for "contact-name" ] [ text "Contact Name" ]
                    , input [ id "contact-name", type_ "contact-name", placeholder "Required", onInput ContactName ] []
                    , span
                        [ class <| validationClass <| getError model "conact.name"
                        , style [ ( "visibility", validationVisibility <| getError model "contact.name" ) ]
                        ]
                        [ text "Contact name must be present" ]
                    ]
                , li []
                    [ label [ for "contact-email" ] [ text "Contact Email" ]
                    , input [ id "contact-email", type_ "contact-email", placeholder "Required", onInput ContactEmail ] []
                    , span
                        [ class <| validationClass <| getError model "contact.email"
                        , style [ ( "visibility", validationVisibility <| getError model "contact.email" ) ]
                        ]
                        [ text "Contact email must be present" ]
                    ]
                , li [ class "section-start" ]
                    [ label [ for "event-name" ] [ text "Event Name" ]
                    , input [ id "event-name", type_ "event-name", placeholder "Required", onInput EventName ] []
                    , span
                        [ class <| validationClass <| getError model "event.name"
                        , style [ ( "visibility", validationVisibility <| getError model "event.name" ) ]
                        ]
                        [ text "Event name must be present" ]
                    ]
                , li []
                    [ label [ for "event-intro" ] [ text "Event Intro" ]
                    , input [ id "event-intro", type_ "event-intro", onInput EventIntro ] []
                    , emptyValidationView
                    ]
                , li [ class "section-start" ]
                    [ label [ for "event-venue-name" ] [ text "Venue Name" ]
                    , input [ id "event-venue-name", type_ "event-venue-name", placeholder "Required", onInput EventVenueName ] []
                    , span
                        [ class <| validationClass <| getError model "venue.name"
                        , style [ ( "visibility", validationVisibility <| getError model "venue.name" ) ]
                        ]
                        [ text "Venue name must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-address1" ] [ text "Street Address" ]
                    , input [ id "event-venue-address1", type_ "event-venue-address1", placeholder "Required", onInput EventVenueAddress1 ] []
                    , span
                        [ class <| validationClass <| getError model "venue.street_address"
                        , style [ ( "visibility", validationVisibility <| getError model "venue.street_address" ) ]
                        ]
                        [ text "Street address must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-city" ] [ text "City" ]
                    , input [ id "event-venue-city", type_ "event-venue-city", placeholder "Required", onInput EventVenueCity ] []
                    , span
                        [ class <| validationClass <| getError model "venue.city"
                        , style [ ( "visibility", validationVisibility <| getError model "venue.city" ) ]
                        ]
                        [ text "City must be present" ]
                    ]
                , li []
                    [ label [ for "event-venue-state" ] [ text "State" ]
                    , input [ id "event-venue-state", type_ "event-venue-state", placeholder "Required", onInput EventVenueState ] []
                    , span
                        [ class <| validationClass <| getError model "venue.state"
                        , style [ ( "visibility", validationVisibility <| getError model "venue.state" ) ]
                        ]
                        [ text "State must be present" ]
                    ]
                , li [ class <| submitButtonClass model ]
                    [ label [] []
                    , button [ onClick SubmitEvent ] [ text "Submit Event" ]
                    , emptyValidationView
                    ]
                ]
            ]
        , div [ id "display-event", style [ ( "display", "none" ) ] ]
            [ div [] [ text <| "Start Time: " ++ formatTimestamp model.event.startTimestamp ]
            , div [] [ text <| "End Time: " ++ formatTimestamp model.event.endTimestamp ]
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


formatTimestamp : EditingTimestamp -> String
formatTimestamp timestamp =
    serializeTimestamp timestamp


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
            if borderTime == startTime then
                ( [ id "startHour", onInput (Hour startTime) ]
                , [ id "startMinute", onInput (Minute startTime) ]
                , [ id "startMeridiem", onInput (Meridiem startTime) ]
                )
            else
                ( [ id "endHour", onInput (Hour endTime) ]
                , [ id "endMinute", onInput (Minute endTime) ]
                , [ id "endMeridiem", onInput (Meridiem endTime) ]
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


dateErrorView : Model -> Html Msg
dateErrorView model =
    span
        [ class <| validationClass <| getError model "date"
        , style [ ( "visibility", validationVisibility <| showDateError model ) ]
        ]
        [ text "End Time must be after Start Time" ]


showDateError : Model -> Bool
showDateError model =
    getError model "date"


emptyValidationView : Html Msg
emptyValidationView =
    span [ class <| validationClass False ] []
