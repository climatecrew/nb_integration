module UpdateTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Types exposing (..)
import Update exposing (..)
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

                        newErrors =
                            Dict.update "event.name" (\_ -> Just True) defaultValidationErrors

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

                        newErrors =
                            Dict.update "venue.name" (\_ -> Just True) defaultValidationErrors

                        newModel =
                            updateEventVenueName model <| Just ""
                    in
                        Expect.equal (getError newModel "venue.name") True
            ]
        ]
