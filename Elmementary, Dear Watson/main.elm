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
  div [ ]
      [ section
          []
          [ lazy viewInput model.field
          , lazy2 viewEntries model.visibility model.entries
          , lazy2 viewControls model.visibility model.entries
          ]
      , infoFooter
      ]

viewInput : String -> Html Msg
viewInput grocery =
  header  []
          [ h1 [] [ text "Grocery List" ]
          , input
              [ placeholder "What to buy?"
              , autofocus True
              , value grocery
              , name "newGrocery"
              , onInput UpdateField
              , onEnter Add
              ]
              []
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
            "Completed" ->
                grocery.completed

            "Active" ->
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
                [ type' "checkbox"
                , name "toggle"
                , checked allCompleted
                , onClick (CheckAll (not allCompleted))
                ]
                []
            , label
                [ for "toggle-all" ]
                [ text "Mark all as complete" ]
            , Keyed.ul [] <|
                List.map viewKeyedEntry (List.filter isVisible entries)
            ]

-- View individual entries

viewKeyedEntry : Entry -> ( String, Html Msg )
viewKeyedEntry grocery =
  ( toString grocery.id, lazy viewEntry grocery )

viewEntry : Entry -> Html Msg
viewEntry grocery =
  li  []
      [ div []
            [ input
                [ type' "checkbox"
                , checked grocery.completed
                , onClick (Check grocery.id (not grocery.completed))
                ]
                []
            , label
                [ onDoubleClick (EditingEntry grocery.id True) ]
                [ text grocery.description ]
            , button
                [ onClick (Delete grocery.id) ]
                [ text "x" ]
            ]
      , input
            [ value grocery.description
            , name "title"
            , id ("grocery-" ++ toString grocery.id)
            , onInput (UpdateEntry grocery.id)
            , onBlur (EditingEntry grocery.id False)
            , onEnter (EditingEntry grocery.id False)
            ]
            []
      ]

-- View controls and footer

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
    span  []
          [ strong [] [ text (toString entriesLeft) ]
          , text (item_ ++ " left")
          ]

viewControlsFilters : String -> Html Msg
viewControlsFilters visibility =
  ul  []
      [ visibilitySwap "#/" "All" visibility
      , text " "
      , visibilitySwap "#/active" "Active" visibility
      , text " "
      , visibilitySwap "#/completed" "Completed" visibility
      ]

visibilitySwap : String -> String -> String -> Html Msg
visibilitySwap uri visibility actualVisibility =
  li
    [ onClick (ChangeVisibility visibility) ]
    [ a [ href uri, classList [ ( "selected", visibility == actualVisibility ) ] ]
        [ text visibility ]
    ]

viewControlsClear : Int -> Html Msg
viewControlsClear entriesCompleted =
  button
    [ hidden (entriesCompleted == 0)
    , onClick DeleteComplete
    ]
    [ text ("Clear completed (" ++ toString entriesCompleted ++ ")") ]

infoFooter : Html msg
infoFooter =
  footer  [ ]
          [ p [] [ ] ]
