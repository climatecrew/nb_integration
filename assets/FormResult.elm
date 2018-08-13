module FormResult exposing (FormResult, resultView, initialFormResult, successResult, errorResult)

import Html exposing (Html, text, label, ul, li, div)
import Html.Attributes exposing (class)


type FormResult
    = NotYetObtained
    | Errors String (List String)
    | Success String


initialFormResult : FormResult
initialFormResult =
    NotYetObtained


errorResult : String -> List String -> FormResult
errorResult message distinctErrors =
    Errors message distinctErrors


successResult : String -> FormResult
successResult message =
    Success message


resultView : FormResult -> List (Html msg)
resultView formResult =
    case formResult of
        NotYetObtained ->
            [ label [ class "results-column-1" ] []
            , text "not yet obtained..."
            ]

        Errors message distinctErrors ->
            [ label [ class "results-column-1" ] []
            , text message
            , div [] [ ul [] <| List.map (\e -> li [] [ text e ]) distinctErrors ]
            ]

        Success message ->
            [ label [ class "results-column-1" ] []
            , text message
            ]
