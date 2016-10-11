-- Start Here!
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import String

main =
  App.beginnerProgram
    { model = model
    , view = view
    , update = update
    }

-- model

type alias Model =
  { list : String }

-- update

type Msg =
  NewContent String | addToList String

update : Msg -> Model -> Model
update msg model =
  case msg of
    NewContent
-- view

view content =
  div []
    [ div [ headStyle ] [ text "Grocery List"]
    , input [ myStyle, placeholder "What to buy?", onInput NewContent, onSubmit addToList] []
    , div [ headStyle ] [ text (content) ]
    ]

-- styles

myStyle =
  style
    [ ("width", "100%")
    , ("height", "40px")
    , ("padding", "10px 0")
    , ("font-size", "2em")
    , ("text-align", "center")
    , ("margin", "0px auto 0px auto")
    ]

headStyle =
  style
    [ ("width", "75%")
    , ("height", "40px")
    , ("padding", "10px 0")
    , ("font-size", "2em")
    , ("text-align", "center")
    , ("margin", "0px auto 0px auto")
    ]
