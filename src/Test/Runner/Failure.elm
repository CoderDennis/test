module Test.Runner.Failure exposing (InvalidReason(..), Reason(..), format)

{-| The reason a test failed.

@docs Reason, InvalidReason, format

-}


{-| The reason a test failed.

Test runners can use this to provide nice output, e.g. by doing diffs on the
two parts of an `Expect.equal` failure.

-}
type Reason
    = Custom
    | Equality String String
    | Comparison String String
      -- Expected, actual, (index of problem, expected element, actual element)
    | ListDiff String String ( Int, String, String )
      {- I don't think we need to show the diff twice with + and - reversed. Just show it after the main vertical bar.
         "Extra" and "missing" are relative to the actual value.
      -}
    | CollectionDiff
        { expected : String
        , actual : String
        , extra : List String
        , missing : List String
        }
    | TODO
    | Invalid InvalidReason


{-| The reason a test run was invalid.

Test runners should report these to the user in whatever format is appropriate.

-}
type InvalidReason
    = EmptyList
    | NonpositiveFuzzCount
    | InvalidFuzzer
    | BadDescription
    | DuplicatedName


verticalBar : String -> String -> String -> String
verticalBar comparison expected actual =
    [ actual
    , "╷"
    , "│ " ++ comparison
    , "╵"
    , expected
    ]
        |> String.join "\n"


{-| DEPRECATED. In the future, test runners should implement versions of this
that make sense for their own environments.

Format test run failures in a reasonable way.

-}
format :
    { description : String
    , given : Maybe String
    , reason : Reason
    }
    -> String
format { description, given, reason } =
    case reason of
        Custom ->
            description

        Equality e a ->
            verticalBar description e a

        Comparison e a ->
            verticalBar description e a

        TODO ->
            description

        Invalid BadDescription ->
            if description == "" then
                "The empty string is not a valid test description."
            else
                "This is an invalid test description: " ++ description

        Invalid _ ->
            description

        ListDiff e a ( i, itemE, itemA ) ->
            String.join ""
                [ verticalBar description e a
                , "\n\nThe first diff is at index "
                , toString i
                , ": it was `"
                , itemA
                , "`, but `"
                , itemE
                , "` was expected."
                ]

        CollectionDiff { expected, actual, extra, missing } ->
            let
                extraStr =
                    if List.isEmpty extra then
                        ""
                    else
                        "\nThese keys are extra: "
                            ++ (extra |> String.join ", " |> (\d -> "[ " ++ d ++ " ]"))

                missingStr =
                    if List.isEmpty missing then
                        ""
                    else
                        "\nThese keys are missing: "
                            ++ (missing |> String.join ", " |> (\d -> "[ " ++ d ++ " ]"))
            in
            String.join ""
                [ verticalBar description expected actual
                , "\n"
                , extraStr
                , missingStr
                ]
