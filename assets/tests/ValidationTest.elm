module ValidationTest exposing (..)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Types exposing (Model, defaultModel, ValidationErrors, getError, setError)
import Validation exposing (validationErrors)


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
                        Expect.equal (getError model "event.name") False
            , test "gets the updated error with the given key" <|
                \_ ->
                    let
                        model =
                            setError defaultModel "event.name" True
                    in
                        Expect.equal (getError model "event.name") True
            ]
        , describe "Validation.setError"
            [ test "sets the error with the given key" <|
                \_ ->
                    let
                        preModel =
                            defaultModel

                        model =
                            { preModel | validationErrors = validationErrors preModel }

                        updatedModel =
                            setError model "event.name" True
                    in
                        Expect.equal (getError updatedModel "event.name") True
            ]
        ]
