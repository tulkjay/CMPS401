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
                { gi | quantity = gi.quantity + 1 }
            else
                gi
      in
        { model | entries = List.map updateEntry model.entries }
            ! []

    Decrement id ->
      let
        updateEntry gi =
            if gi.id == id && gi.quantity > 0 then
                { gi | quantity = gi.quantity - 1 }
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

-- view

view : Model -> Html Msg
view model =
  div [ class "outer-container" ]
      [ section
          [ class "container" ]
          [ lazy viewInput model.field
          , lazy2 viewEntries model.visibility model.entries
          , lazy2 viewControls model.visibility model.entries
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
            ,span []
                  [ span [] [ text (toString grocery.quantity) ]
                  , button [ onClick (Decrement grocery.id)] [ text "-" ]
                  , button [ onClick (Increment grocery.id)] [ text "+" ]
                  ]
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
        p [ class "filter-header"]
          [ text "Filters:"]
        , ul  [ class "filter-list"]
            [ visibilitySwap "#/" "All" visibility
            , text " "
            , visibilitySwap "#/active" "On the Shelf" visibility
            , text " "
            , visibilitySwap "#/completed" "In the Buggy" visibility
            ]
      ]


visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
  li
    [ onClick (ChangeVisibility visibility) ]
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
