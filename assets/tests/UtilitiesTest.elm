module UtilitiesTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Utilities exposing (..)
import EditingTimestamp exposing (EditingTimestamp, BorderTime(..))


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
        , describe "Utilities.serializeTimestamp"
            [ test "serializes an AM timestamp as-is" <|
                \_ ->
                    let
                        editingTimestamp =
                            { border = StartTime
                            , ymd = "2018-09-03"
                            , hour = 11
                            , minute = 30
                            , meridiem = "AM"
                            }
                    in
                        Expect.equal (serializeTimestamp editingTimestamp) "2018-09-03T11:30:00-04:00"
            , test "serializes a PM timestamp in 24-hour format" <|
                \_ ->
                    let
                        editingTimestamp =
                            { border = StartTime
                            , ymd = "2018-09-03"
                            , hour = 11
                            , minute = 30
                            , meridiem = "PM"
                            }
                    in
                        Expect.equal (serializeTimestamp editingTimestamp) "2018-09-03T23:30:00-04:00"
            , test "pads hour and minute if needed" <|
                \_ ->
                    let
                        editingTimestamp =
                            { border = StartTime
                            , ymd = "2018-09-03"
                            , hour = 1
                            , minute = 0
                            , meridiem = "AM"
                            }
                    in
                        Expect.equal (serializeTimestamp editingTimestamp) "2018-09-03T01:00:00-04:00"
            ]
        ]
