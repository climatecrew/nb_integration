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


initialModel : Flags -> Model
initialModel flags =
    { defaultModel
        | rootURL = flags.rootURL
        , slug = flags.slug
        , validationErrors = validationErrors defaultModel
    }


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
            ( updateEventVenueStreetAddress model <| Just address1, Cmd.none )

        EventVenueCity city ->
            ( updateEventVenueCity model <| Just city, Cmd.none )

        EventVenueState state ->
            ( updateEventVenueState model <| Just state, Cmd.none )

        EventVenueName name ->
            ( updateEventVenueName model <| Just name, Cmd.none )

        ContactEmail email ->
            ( updateContactEmail model <| Just email, Cmd.none )

        ContactName name ->
            ( updateContactName model <| Just name, Cmd.none )

        Day day ->
            ( updateEventDay model day, Cmd.none )

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
                    touchValidation um1 "date" (datesOk um1)
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
                    touchValidation um1 "date" (datesOk um1)
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
                    touchValidation um1 "date" (datesOk um1)
            in
                ( updatedModel, Cmd.none )

        SubmitEvent ->
            let
                newModel =
                    markEventSubmitted model
            in
                if invalidInput newModel then
                    ( newModel, Cmd.none )
                else
                    ( { newModel | loading = True }
                    , Http.send CreateEventResult (createEvent newModel)
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
