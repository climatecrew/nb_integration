module Main exposing (..)

import Html exposing (Html, programWithFlags)
import Http
import Types exposing (..)
import Views exposing (..)
import Utilities exposing (..)
import Networking exposing (..)
import Validation exposing (..)
import Update exposing (..)
import EditingTimestamp exposing (startTime)


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
            initialModel flags
    in
        ( model, Http.send FetchEventsResult (getEvents model) )


subscriptions : Model -> Sub msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    mainView model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EventName name ->
            ( updateEventName model name, Cmd.none )

        EventIntro intro ->
            ( updateEventIntro model intro, Cmd.none )

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

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "venue.street_address" (not <| streetAddressPresent um1)
            in
                ( updatedModel, Cmd.none )

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

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "venue.city" (not <| cityPresent um1)
            in
                ( updatedModel, Cmd.none )

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

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "venue.state" (not <| statePresent um1)
            in
                ( updatedModel, Cmd.none )

        EventVenueName name ->
            ( updateEventVenueName model <| Just name, Cmd.none )

        ContactEmail email ->
            let
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

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "contact.email" (String.length email == 0)
            in
                ( updatedModel, Cmd.none )

        ContactName name ->
            let
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

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "contact.name" (String.length name == 0)
            in
                ( updatedModel, Cmd.none )

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
                            if borderTime == startTime then
                                ev.startTimestamp
                            else
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
                        if borderTime == startTime then
                            { ev | startTimestamp = updatedTS }
                        else
                            { ev | endTimestamp = updatedTS }

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "date" (not <| datesOk um1)
            in
                ( updatedModel, Cmd.none )

        Minute borderTime minute ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentTS =
                            if borderTime == startTime then
                                ev.startTimestamp
                            else
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
                        if borderTime == startTime then
                            { ev | startTimestamp = updatedTS }
                        else
                            { ev | endTimestamp = updatedTS }

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "date" (not <| datesOk um1)
            in
                ( updatedModel, Cmd.none )

        Meridiem borderTime meridiem ->
            let
                ev =
                    model.event

                updatedEvent =
                    let
                        currentTS =
                            if borderTime == startTime then
                                ev.startTimestamp
                            else
                                ev.endTimestamp

                        updatedTS =
                            { currentTS | meridiem = meridiem }
                    in
                        if borderTime == startTime then
                            { ev | startTimestamp = updatedTS }
                        else
                            { ev | endTimestamp = updatedTS }

                um1 =
                    { model | event = updatedEvent }

                updatedModel =
                    setError um1 "date" (not <| datesOk um1)
            in
                ( updatedModel, Cmd.none )

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
