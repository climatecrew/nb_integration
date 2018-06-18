module ValidationTest exposing (..)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Types exposing (Model, defaultModel, ValidationErrors)
import Validation exposing (validationErrors, getError, setValid)


suite : Test
suite =
    describe "Validation module"
        [ describe "Validation.getError"
            [ test "gets the error with the given key" <|
                \_ ->
                    let
                        preModel =
                            defaultModel

                        model =
                            { preModel | validationErrors = validationErrors preModel }
                    in
                        Expect.equal (getError model "event.name") True
            , test "gets the updated error with the given key" <|
                \_ ->
                    let
                        model =
                            setValid defaultModel "event.name" True
                    in
                        Expect.equal (getError model "event.name") False
            ]
        , describe "Validation.setValid"
            [ test "sets the error with the given key" <|
                \_ ->
                    let
                        preModel =
                            defaultModel

                        model =
                            { preModel | validationErrors = validationErrors preModel }

                        updatedModel =
                            setValid model "event.name" True
                    in
                        Expect.equal (getError updatedModel "event.name") True
            ]
        ]
