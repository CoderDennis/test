module Descendant exposing (all)

-- TODO: rename to Test.Html.DescendantTest

import ElmHtml.InternalTypes exposing (ElmHtml(..))
import Expect
import Html exposing (..)
import Html.Inert exposing (fromHtml, toElmHtml)
import Test exposing (..)
import Test.Html.Descendant exposing (isDescendant)
import Test.Html.Query as Query exposing (Single)


wrapper : Html msg -> Html msg -> Bool
wrapper html potentialDescendant =
    let
        elmHtml =
            [ htmlToElm html ]

        potentialDescendantElmHtml =
            htmlToElm potentialDescendant
    in
    isDescendant elmHtml potentialDescendantElmHtml


all : Test
all =
    describe "Contains assertion"
        [ test "returns true if it contains the expected html once" <|
            \() ->
                let
                    aSingleDescendant =
                        someTitle "foo"

                    html =
                        div [] [ aSingleDescendant ]
                in
                wrapper html aSingleDescendant
                    |> Expect.equal True
        , test "returns true if it contains the expected html more than once" <|
            \() ->
                let
                    aMultiInstanceDescendant =
                        someTitle "foo"

                    html =
                        div []
                            [ aMultiInstanceDescendant
                            , aMultiInstanceDescendant
                            ]
                in
                wrapper html aMultiInstanceDescendant
                    |> Expect.equal True
        , test "return true if the node is a nested descendant" <|
            \() ->
                let
                    aNestedDescendant =
                        someTitle "foo"

                    html =
                        div []
                            [ div []
                                [ div [] [ aNestedDescendant ]
                                ]
                            ]
                in
                wrapper html aNestedDescendant
                    |> Expect.equal True
        , test "returns false if it does not contain the node" <|
            \() ->
                let
                    notInHtml =
                        img [] []

                    html =
                        div [] [ someTitle "foo" ]
                in
                wrapper html notInHtml
                    |> Expect.equal False
        ]


someTitle : String -> Html msg
someTitle str =
    h1 [] [ text str ]


htmlToElm : Html msg -> ElmHtml msg
htmlToElm =
    toElmHtml << fromHtml
