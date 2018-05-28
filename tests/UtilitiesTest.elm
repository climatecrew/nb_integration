module UtilitiesTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Utilities exposing (..)


suite : Test
suite =
    describe "Utilities module"
        [ describe "Utilities.padTimePart"
            [ test "echoes back a two-digit value" <|
                \_ ->
                    Expect.equal (padTimePart 10) "10"
            , test "left-pads a one-digit value with a 0" <|
                \_ ->
                    Expect.equal (padTimePart 9) "09"
            ]
        ]
