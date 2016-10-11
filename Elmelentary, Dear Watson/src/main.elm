-- Start Here!
import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import String

main =
  App.beginnerProgram
    { model = ""
    , view = view
    , update = update
    }

-- model

-- update

type Msg =
  NewContent String

update (NewContent content) oldContent =
  content

-- view

view content =
  div []
    [ div [ headStyle ] [ text "Grocery List"]
    , input [ myStyle, placeholder "What to buy?", onInput NewContent] []
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
