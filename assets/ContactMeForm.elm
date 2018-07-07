module ContactMeForm exposing (..)

import ContactMeTypes exposing (Flags)
import FormInput exposing (FormInput, setupNonInteractiveInput, setupInteractiveInput, inputView)


type alias Form =
    { submitted : Bool
    , firstName : FormInput
    , lastName : FormInput
    , email : FormInput
    , phone : FormInput
    }


setupForm : Flags -> Form
setupForm flags =
    let
        isValid =
            (\val -> String.length val > 0)

        firstNameInput =
            case flags.nbPersonID of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { value = ""
                        , placeholder = "Required"
                        , label = "First Name"
                        , for = "first_name"
                        , id = "first_name"
                        , type_ = "first_name"
                        , touched = False
                        , isValid = isValid
                        , errorMessage = (\val -> "First Name is required")
                        }

                Just _ ->
                    FormInput.setupNonInteractiveInput
                        { value = Maybe.withDefault "" flags.nbFirstName }

        lastNameInput =
            case flags.nbPersonID of
                Nothing ->
                    FormInput.setupInteractiveInput
                        { value = ""
                        , placeholder = "Required"
                        , label = "Last Name"
                        , for = "last_name"
                        , id = "last_name"
                        , type_ = "last_name"
                        , touched = False
                        , isValid = isValid
                        , errorMessage = (\val -> "Last Name is required")
                        }

                Just _ ->
                    FormInput.setupNonInteractiveInput
                        { value = Maybe.withDefault "" flags.nbLastName }

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
        , firstName = firstNameInput
        , lastName = lastNameInput
        , email = emailInput
        , phone = phoneInput
        }


updateFirstName : Form -> String -> Form
updateFirstName form value =
    { form | firstName = FormInput.updateFormInput form.firstName value }


updateLastName : Form -> String -> Form
updateLastName form value =
    { form | lastName = FormInput.updateFormInput form.lastName value }


updateEmail : Form -> String -> Form
updateEmail form value =
    { form | email = FormInput.updateFormInput form.email value }


updatePhone : Form -> String -> Form
updatePhone form value =
    { form | phone = FormInput.updateFormInput form.phone value }
