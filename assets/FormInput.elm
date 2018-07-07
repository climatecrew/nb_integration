module FormInput exposing (FormInput, TextInputType(..), setupNonInteractiveInput, setupInteractiveInput, updateFormInput, inputView)

import Html exposing (Html, span, text, input, textarea, label)
import Html.Attributes exposing (id, class, placeholder, style, type_, for, rows, value)
import Html.Events exposing (onInput)
import ContactMeTypes exposing (Msg)


type alias InteractiveInput =
    { inputType : TextInputType
    , value : String
    , placeholder : String
    , id : String
    , label : String
    , for : String
    , type_ : String
    , touched : Bool
    , isValid : String -> Bool
    , errorMessage : String -> String
    }


type alias NonInteractiveInput =
    { value : String
    }


type TextInputType
    = Input
    | TextArea Int


type FormInput
    = Interactive InteractiveInput
    | NonInteractive NonInteractiveInput


setupInteractiveInput : InteractiveInput -> FormInput
setupInteractiveInput input =
    Interactive input


setupNonInteractiveInput : NonInteractiveInput -> FormInput
setupNonInteractiveInput input =
    NonInteractive input


updateFormInput : FormInput -> String -> FormInput
updateFormInput formInput val =
    case formInput of
        Interactive input ->
            Interactive { input | value = val, touched = True }

        NonInteractive input ->
            NonInteractive { input | value = val }


inputView : Bool -> FormInput -> (String -> Msg) -> List (Html Msg)
inputView formSubmitted formInput inputMsg =
    let
        htmlInput input =
            case input.inputType of
                Input ->
                    Html.input
                        [ id input.id
                        , type_ input.type_
                        , placeholder input.placeholder
                        , value input.value
                        , onInput inputMsg
                        ]
                        []

                TextArea rowCount ->
                    Html.textarea
                        [ id input.id
                        , placeholder input.placeholder
                        , rows rowCount
                        , value input.value
                        , onInput inputMsg
                        ]
                        []

        showValidation input =
            (not <| input.isValid input.value)
                && (input.touched || formSubmitted)
    in
        case formInput of
            NonInteractive _ ->
                []

            Interactive input ->
                [ label [ for input.for ] [ text input.label ]
                , htmlInput input
                , span
                    [ class "validation"
                    , style [ ( "visibility", validationVisibility <| showValidation input ) ]
                    ]
                    [ text <| validationMessage input ]
                ]


validationVisibility : Bool -> String
validationVisibility showErrors =
    if showErrors then
        "visible"
    else
        "hidden"


validationMessage : InteractiveInput -> String
validationMessage input =
    if input.isValid input.value then
        ""
    else
        input.errorMessage input.value
