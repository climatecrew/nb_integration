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
        [ describe "Update.updateModelEvent"
            [ test "sets the model event" <|
                \_ ->
                    let
                        model =
                            defaultModel

                        newEvent =
                            { defaultEvent | id = 2 }

                        newModel =
                            updateModelEvent model newEvent
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
        ]
