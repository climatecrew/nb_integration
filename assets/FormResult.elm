module FormResult exposing (FormResult, errorResult, initialFormResult, resultView, successResult)

import Html exposing (Html, div, label, li, text, ul)
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
    let
        placeholderLabel =
            label [] []
    in
    case formResult of
        NotYetObtained ->
            [ li []
                [ placeholderLabel
                , text ""
                ]
            ]

        Errors message distinctErrors ->
            let
                errorItems =
                    List.map (\e -> li [] [ placeholderLabel, text e ]) distinctErrors
            in
            li [] [ placeholderLabel, text message ] :: errorItems

        Success message ->
            [ li []
                [ placeholderLabel
                , text message
                ]
            ]
