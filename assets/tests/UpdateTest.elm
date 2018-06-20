module UpdateTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Types exposing (..)
import Update exposing (..)
import Validation exposing (validationErrors, getError, setValid)
import Dict


suite : Test
suite =
    describe "Update module"
        [ describe "Update.updateEvent"
            [ test "sets the model event" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newEvent =
                            { defaultEvent | id = 2 }

                        newModel =
                            updateEvent model newEvent
                    in
                        Expect.equal newModel.event newEvent
            ]
        , describe "Update.updateEventName"
            [ test "sets the model event name" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newEvent =
                            { defaultEvent | name = "A new name" }

                        newModel =
                            updateEventName model "A new name"
                    in
                        Expect.equal newModel.event.name "A new name"
            , test "sets error if event name is empty" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newModel =
                            updateEventName model ""
                    in
                        Expect.equal (getError newModel "event.name") True
            ]
        , describe "Update.updateEventIntro"
            [ test "sets the model event intro" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newEvent =
                            { defaultEvent | intro = "Welcome to The Rock" }

                        newModel =
                            updateEventIntro model "Welcome to The Rock"
                    in
                        Expect.equal newModel.event newEvent
            ]
        , describe "Update.updateEventVenue"
            [ test "sets the model event venue" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newVenue =
                            { defaultVenue | name = Just "New Name" }

                        newEvent =
                            { defaultEvent | venue = newVenue }

                        newModel =
                            updateEventVenue model newVenue
                    in
                        Expect.equal newModel.event.venue newVenue
            ]
        , describe "Update.updateEventVenueName"
            [ test "sets the model event venue name" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newModel =
                            updateEventVenueName model <| Just "New Name"
                    in
                        Expect.equal newModel.event.venue.name <| Just "New Name"
            , test "sets error if name is an empty string" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newModel =
                            updateEventVenueName model <| Just ""
                    in
                        Expect.equal (getError newModel "venue.name") True
            ]
        , describe "Update.updateEventVenueAddress"
            [ test "sets the model event venue address" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newAddress =
                            { defaultAddress | address1 = Just "123 Main St." }

                        newModel =
                            updateEventVenueAddress model <| Just newAddress
                    in
                        Expect.equal newModel.event.venue.address <| Just newAddress
            ]
        , describe "Update.updateEventVenueStreetAddress"
            [ test "sets the model event venue street address" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newAddress =
                            { defaultAddress | address1 = Just "123 Main St." }

                        newModel =
                            updateEventVenueStreetAddress model <| Just "123 Main St."
                    in
                        Expect.equal newModel.event.venue.address <| Just newAddress
            , test "sets error if street_address is an empty string" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newModel =
                            updateEventVenueStreetAddress model <| Just ""
                    in
                        Expect.equal (getError newModel "venue.street_address") True
            ]
        , describe "Update.updateEventVenueCity"
            [ test "sets the model event venue city" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newAddress =
                            { defaultAddress | city = Just "Boston" }

                        newModel =
                            updateEventVenueCity model <| Just "Boston"
                    in
                        Expect.equal newModel.event.venue.address <| Just newAddress
            , test "sets error if city is an empty string" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newModel =
                            updateEventVenueCity model <| Just ""
                    in
                        Expect.equal (getError newModel "venue.city") True
            , test "sets error if city is a Nothing" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newAddress =
                            { defaultAddress | city = Nothing }

                        newModel =
                            updateEventVenueCity model Nothing
                    in
                        Expect.equal (getError newModel "venue.city") True
            ]
        , describe "Update.updateEventVenueState"
            [ test "sets the model event venue state" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newAddress =
                            { defaultAddress | state = Just "MA" }

                        newModel =
                            updateEventVenueState model <| Just "MA"
                    in
                        Expect.equal newModel.event.venue.address <| Just newAddress
            , test "sets error if state is an empty string" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newModel =
                            updateEventVenueState model <| Just ""
                    in
                        Expect.equal (getError newModel "venue.state") True
            , test "sets error if state is a Nothing" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newAddress =
                            { defaultAddress | state = Nothing }

                        newModel =
                            updateEventVenueState model Nothing
                    in
                        Expect.equal (getError newModel "venue.state") True
            ]
        ]
