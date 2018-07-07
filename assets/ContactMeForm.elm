module ContactMeForm exposing (..)

import ContactMeTypes exposing (Flags)
import FormInput exposing (FormInput, setupNonInteractiveInput, setupInteractiveInput, inputView)


type alias Form =
    { submitted : Bool
    , email : FormInput
    }


setupForm : Flags -> Form
setupForm flags =
    let
        isValid =
            (\val -> String.length val > 0)

        emailInput =
            case flags.nbEmail of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { value = ""
                        , placeholder = "Required"
                        , label = "Email"
                        , for = "email"
                        , id = "email"
                        , type_ = "email"
                        , touched = False
                        , isValid = isValid
                        , errorMessage = (\val -> "Email is required")
                        }

                Just email ->
                    FormInput.setupNonInteractiveInput
                        { value = "" }
    in
        { submitted = False
        , email = emailInput
        }


updateEmail : Form -> String -> Form
updateEmail form value =
    { form | email = FormInput.updateFormInput form.email value }
