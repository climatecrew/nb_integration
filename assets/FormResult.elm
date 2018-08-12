module FormResult exposing (FormResult, resultView, updateResult, initialFormResult)

import Html exposing (Html, text, label)
import Html.Attributes exposing (class)
import ContactMeTypes exposing (APIResult)


type FormResult
    = NotYetObtained
    | Obtained APIResult


initialFormResult : FormResult
initialFormResult =
    NotYetObtained


updateResult : FormResult -> Maybe APIResult -> FormResult
updateResult formResult value =
    case value of
        Just result ->
            Obtained result

        Nothing ->
            NotYetObtained


resultView : FormResult -> List (Html msg)
resultView formResult =
    case formResult of
        NotYetObtained ->
            [ label [ class "results-column-1" ] []
            , text "not yet obtained..."
            ]

        Obtained apiResult ->
            case apiResult of
                ContactMeTypes.APIErrors errors ->
                    [ label [ class "results-column-1" ] []
                    , text <| String.concat [ "results: ", List.map (\e -> e.title) errors |> String.join ", " ]
                    ]

                otherwise ->
                    [ label [ class "results-column-1" ] []
                    , text "results: succeeded"
                    ]
