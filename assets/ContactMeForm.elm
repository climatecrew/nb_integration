module ContactMeForm exposing (..)

import ContactMeTypes exposing (Flags)
import FormInput exposing (FormInput, setupNonInteractiveInput, setupInteractiveInput, inputView)


type alias Form =
    { submitted : Bool
    , email : FormInput
    , phone : FormInput
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
                        { value = email }

        phoneInput =
            case flags.nbPhone of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { value = ""
                        , placeholder = ""
                        , label = "Phone"
                        , for = "phone"
                        , id = "phone"
                        , type_ = "text"
                        , touched = False
                        , isValid = (\_ -> True)
                        , errorMessage = (\_ -> "")
                        }

                Just phone ->
                    FormInput.setupNonInteractiveInput
                        { value = phone }
    in
        { submitted = False
        , email = emailInput
        , phone = phoneInput
        }


updateEmail : Form -> String -> Form
updateEmail form value =
    { form | email = FormInput.updateFormInput form.email value }


updatePhone : Form -> String -> Form
updatePhone form value =
    { form | phone = FormInput.updateFormInput form.phone value }
