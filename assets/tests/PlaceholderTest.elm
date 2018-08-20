module PlaceholderTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)


suite : Test
suite =
    describe "Placeholder test module"
        [ describe "ModuleName.functionName"
            [ test "1 == 1" <|
                \_ ->
                    Expect.equal 1 1
            ]
        ]
