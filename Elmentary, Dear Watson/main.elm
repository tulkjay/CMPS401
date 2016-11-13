port module Main exposing (..)

import Dom
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2)
import Json.Decode as Json
import String
import Task

main : Program (Maybe Model)
main =
  App.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

-- model

type alias Model =
  { entries : List Entry
  , field : String
  , uid : Int
  , visibility : String
  }

type alias Entry =
  { description : String
  , completed : Bool
  , editing : Bool
  , quantity : Int
  , analysis : String
  , id : Int
  }

emptyModel : Model
emptyModel =
  { entries = []
  , visibility = "All"
  , field = ""
  , uid = 0
  }

newEntry : String -> Int -> Entry
newEntry desc id =
  { description = desc
  , completed = False
  , editing = False
  , quantity = 0
  , analysis = ""
  , id = id
  }

init : Maybe Model -> ( Model, Cmd Msg )
init savedModel =
  Maybe.withDefault emptyModel savedModel ! []

-- update

type Msg
  = NoOp
  | UpdateField String
  | EditingEntry Int Bool
  | UpdateEntry Int String
  | Add
  | Delete Int
  | Increment Int
  | Decrement Int
  | DeleteComplete
  | Check Int Bool
  | CheckAll Bool
  | ChangeVisibility String
  | ChangeFilter String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      model ! []

    Add ->
      { model
          | uid = model.uid + 1
          , field = ""
          , entries =
              if String.isEmpty model.field then
                  model.entries
              else
                  model.entries ++ [ newEntry model.field model.uid ]
      }
          ! []

    UpdateField str ->
      { model | field = str }
          ! []

    EditingEntry id isEditing ->
      let
        updateEntry gi =
          if gi.id == id then
              { gi | editing = isEditing }
          else
              gi
        focus =
          Dom.focus ("grocery-" ++ toString id)
      in
        { model | entries = List.map updateEntry model.entries }
            ! []

    UpdateEntry id grocery ->
      let
        updateEntry gi =
            if gi.id == id then
                { gi | description = grocery }
            else
                gi
      in
        { model | entries = List.map updateEntry model.entries }
            ! []

    Delete id ->
      { model | entries = List.filter (\gi -> gi.id /= id) model.entries }
          ! []

    Increment id ->
      let
        updateEntry gi =
            if gi.id == id then
                { gi
                | quantity = gi.quantity + 1
                , analysis = case gi.quantity + 1 of
                               0 -> "You need at least one."
                               1 -> "Nice, you're getting it!"
                               2 -> "Two, also a reasonable quantity..."
                               3 -> "Three, the perfect maximum amount!"
                               4 -> "How nice of you, getting food for the whole family."
                               7 -> "One of us needs to settle down, now."
                               10 -> "Okay..."
                               13 -> ""
                               18 -> "Yeah, I'm still here."
                               22 -> "You're kidding, right?"
                               30 -> "I don't even care anymore, I quit!"
                               35 -> "Seriously, I quit!!!"
                               _ -> gi.analysis}
            else
                gi
      in
        { model | entries = List.map updateEntry model.entries }
            ! []

    Decrement id ->
      let
        updateEntry gi =
            if gi.id == id && gi.quantity > 0 then
                { gi
                | quantity = gi.quantity - 1
                , analysis = case gi.quantity - 1 of
                               0 -> "You need at least one."
                               1 -> "One is all you need."
                               2 -> "That's what I call self control."
                               3 -> "I thought so, too."
                               5 -> "Much better."
                               8 -> "Snap back to reality."
                               12 -> "Lower..."
                               18 -> "You really think that's enough? Keep going!"
                               22 -> "Yeah, not even close, keep clicking"
                               25 -> "Alright, fine. I forgive you."
                               30 -> "Yeah, like that is going to make me happy now."
                               34 -> "It's too late! We're done!"
                               _ -> gi.analysis }
            else
                gi
      in
        { model | entries = List.map updateEntry model.entries }
            ! []

    DeleteComplete ->
      { model | entries = List.filter (not << .completed) model.entries }
          ! []

    Check id isCompleted ->
      let
        updateEntry gi =
            if gi.id == id then
                { gi | completed = isCompleted }
            else
                gi
      in
        { model | entries = List.map updateEntry model.entries }
            ! []

    CheckAll isCompleted ->
      let
        updateEntry gi =
            { gi | completed = isCompleted }
      in
          { model | entries = List.map updateEntry model.entries }
              ! []

    ChangeVisibility visibility ->
      { model | visibility = visibility }
          ! []

    ChangeFilter description ->
      let
        updateEntry gi =
            { gi | description = case description of
                                  "Health Food" -> case gi.description of
                                                      "Pizza" -> "Pizza = Heart Attack Pie"
                                                      "Ice Cream" -> "Ice Cream = Frozen Cow Fluid"
                                                      "Cake" -> "Cake = Pound Up"
                                                      "Taco"-> "Taco = Loco"
                                                      "Burrito" -> "Burrito = Caca"
                                                      "Chimichanga" -> "No way Jose"
                                                      "Sushi" -> "Sushi = good"
                                                      "Spaghetti" -> "Spaghetti = Momma Mia"
                                                      "Olive" -> "Olive = good"
                                                      "Hamburger"-> "Hamburger = Hamburgler"
                                                      "French Fried Tater" -> "Slingblade, hmmhmm"
                                                      _ -> gi.description

                                  "Mediterranean Food" -> case gi.description of
                                                      "Taco"-> "Taco = Loco"
                                                      "Burrito" -> "Burrito = Caca"
                                                      "Chimichanga" -> "No way Jose"
                                                      "Sushi" -> "Sushi = Too Fishy"
                                                      "Pizza" -> "Pizza = good"
                                                      "Spaghetti" -> "Spaghetti = good"
                                                      "Olive" -> "Olive = good"
                                                      "Ice Cream" -> "Ice Cream = Frozen Cow Fluid"
                                                      "Cake" -> "Cake = Pound Up"
                                                      "Hamburger"-> "Hamburger = Hamburgler"
                                                      "French Fried Tater" -> "Slingblade, hmmhmm"
                                                      _ -> gi.description

                                  "Mexican Food" -> case gi.description of
                                                      "Hamburger"-> "Hamburger = Hamburgler"
                                                      "Calamari" -> "Calamari = Tend to Kills"
                                                      "French Fried Tater" -> "Slingblade, hmmhmm"
                                                      "Taco"-> "Taco = Bueno!"
                                                      "Burrito" -> "Burrito = Bueno!"
                                                      "Chimichanga" -> "Chitty Chitty Bang Bang"
                                                      "Pizza" -> "Pizza = Heart Attack Pie"
                                                      "Ice Cream" -> "Ice Cream = Frozen Cow Fluid"
                                                      "Cake" -> "Cake = Pound Up"
                                                      "Sushi" -> "Sushi = Too Fishy"
                                                      "Spaghetti" -> "Spaghetti = Momma Mia"
                                                      "Olive" -> "Olive = No Bueno"
                                                      _ -> gi.description
                                  _ -> gi.description
                              }
      in
          { model | entries = List.map updateEntry model.entries }
              ! []
-- view

view : Model -> Html Msg
view model =
  div [ class "outer-container" ]
      [ section
          [ class "container" ]
          [ lazy viewInput model.field
          , lazy2 viewControls model.visibility model.entries
          , lazy2 viewEntries model.visibility model.entries
          ]
      ]

viewInput : String -> Html Msg
viewInput grocery =
  header  [ class "header" ]
          [ span [ class "title" ] [ text "Grocery List..." ]
          , br [] []
          , span [ class "sub-title" ] [ text "Commence the list construction!" ]
          , br [] []
          , input
              [ class "item-input"
              , placeholder "New Item"
              , autofocus True
              , value grocery
              , name "newGrocery"
              , onInput UpdateField
              , onEnter Add
              ]
              []
          , button [class "add-button",  onClick (Add)] [ text "Add"]
          ]

onEnter : Msg -> Attribute Msg
onEnter msg =
  let
    tagger code =
        if code == 13 then
            msg
        else
            NoOp
  in
    on "keydown" (Json.map tagger keyCode)

-- View all groceries entered
viewEntries : String -> List Entry -> Html Msg
viewEntries visibility entries =
  let
      isVisible grocery =
        case visibility of
            "In the Buggy" ->
                grocery.completed

            "On the Shelf" ->
                not grocery.completed

            _ ->
                True

      allCompleted =
        List.all .completed entries

      cssVisibility =
          if List.isEmpty entries then
              "hidden"
          else
              "visible"
  in
    section [ style [ ( "visibility", cssVisibility ) ] ]
            [ input
                [ class "checkbox"
                , type' "checkbox"
                , name "toggle"
                , checked allCompleted
                , onClick (CheckAll (not allCompleted))
                ]
                []
            , label
                [ class "label"
                , for "toggle-all" ]
                [ text "Mark all as complete" ]
            , Keyed.ul [ class "item-list" ] <|
                List.map viewKeyedEntry (List.filter isVisible entries)
            ]

-- View entries

viewKeyedEntry : Entry -> ( String, Html Msg )
viewKeyedEntry grocery =
  ( toString grocery.id, lazy viewEntry grocery )

viewEntry : Entry -> Html Msg
viewEntry grocery =
  li  [ class "list"]
      [ div [ class "grocery-list-container"]
            [ input
                [ class "checkbox"
                , type' "checkbox"
                , checked grocery.completed
                , onClick (Check grocery.id (not grocery.completed))
                ]
                []
            ,input
                  [ class "input strike"
                  , value grocery.description
                  , name "title"
                  , id ("grocery-" ++ toString grocery.id)
                  , onInput (UpdateEntry grocery.id)
                  , onBlur (EditingEntry grocery.id False)
                  , onEnter (EditingEntry grocery.id False)
                  ]
                  []
            , span [ class "quantity-text"]
                   [ text (toString grocery.quantity) ]
            , span [ class "quantity-button-group"]
                   [ button [ class "quantity-button"
                   , onClick (Decrement grocery.id)] [ text "-" ]
                   , button [ class "quantity-button"
                   , onClick (Increment grocery.id)] [ text "+" ]
                   ]
            , span [ class "analysis"]
                   [ text grocery.analysis]
            , button
                [ class "remove-button strike"
                , onClick (Delete grocery.id) ]
                [ text "Remove" ]
            ]

      ]

-- View controls

viewControls : String -> List Entry -> Html Msg
viewControls visibility entries =
  let
    entriesCompleted =
        List.length (List.filter .completed entries)

    entriesLeft =
        List.length entries - entriesCompleted

  in
    footer  [ hidden (List.isEmpty entries) ]
            [ lazy viewControlsCount entriesLeft
            , lazy viewControlsFilters visibility
            , lazy viewControlsClear entriesCompleted
            ]

viewControlsCount : Int -> Html Msg
viewControlsCount entriesLeft =
  let
    item_ =
        if entriesLeft == 1 then
            " item"
        else
            " items"
  in
    span  [ class "items-count-span"]
          [ strong [] [ text (toString entriesLeft) ]
          , text (item_ ++ " left")
          ]

viewControlsFilters : String -> Html Msg
viewControlsFilters visibility =
  div [ class "filter-container" ]
      [
        span [ class "filter-header"]
          [ text "Filters:"]
        , ul  [ class "filter-list"]
            [ visibilitySwap "#/" "All" visibility
            , text " "
            , visibilitySwap "#/active" "On the Shelf" visibility
            , text " "
            , visibilitySwap "#/completed" "In the Buggy" visibility
            , text " "
            , filterSwap "#/HealthFood" "Health Food" "Health Food"
            , text " "
            , filterSwap "#/Mediterranean" "Mediterranean Food" "Mediterranean Food"
            , text " "
            , filterSwap "#/Mexican" "Mexican Food" "Mexican Food"
            , text " "

            ]
      ]

filterSwap : String -> String -> String -> Html Msg
filterSwap uri filter filteredDescription =
  li
    [ class "filter-item"
    , onClick (ChangeFilter filteredDescription) ]
    [ a
      [ href uri ]
      [ text filter ]
    ]


visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
  li
    [ class "filter-item"
    , onClick (ChangeVisibility visibility) ]
    [ a
      [ href uri, classList
        [ ( "selected", visibility == actualVisibility ) ]
        ]
      [ text visibility ]
    ]

viewControlsClear : Int -> Html Msg
viewControlsClear entriesCompleted =
  button
    [ hidden (entriesCompleted == 0)
      , class "clear-complete-button"
      , onClick DeleteComplete
    ]
    [ text ("Clear completed (" ++ toString entriesCompleted ++ ")") ]
