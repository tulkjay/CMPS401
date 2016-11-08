# CMPS401
* Survey of programming languages

## Program Elm:
* Shopping List
 *Interactive*

* For Midterms:
  * User can:
  * Add shopping categories,
  * Add items to list (in categories).

## Getting Started
* Prerequisites
  * Node.js
* Setting up an empty Elm project
  * On the elm website, install Elm Platform
  * After installing, run `elm-package install elm-lang/core` in the command prompt.
    * Follow the prompts to create an Elm project in your current directory.
  * Enter `elm-reactor` to start the project on port 8000.

## Adding A CSS File
### Note
  While it is easy to configure your project to use an external CSS file, I suggest that you build as much of the UI as you can before trying to apply styles. While there are multiple reasons for this, the main one is the it will save a lot of loading time on your part later on.

  * Setting up
    * In your main elm file, add at the beginning (replace YourFileName with a capitalized version of your file. ie: main => Main):
    ```elm
    port module YourFileName exposing (..)
    ```
    * Add a file to your project called `index.html`.
    * In index.html, insert (again replacing YourPortedFileName with the capitalized name of your elm file. ie: main => Main):  
    ```html
        <!DOCTYPE HTML>
        <html>
        <head>
          <meta charset="utf-8">
          <title>Your Title</title>
          <script type="text/javascript" src="elm.js"></script>
          <link rel="stylesheet" href="styles.css">
        </head>

        <body>
        </body>

        <script type="text/javascript">
        Elm.YourPortedFileName.fullscreen();
        </script>
        </html>
  ```    
    * Add a new file called "styles.css" to your project. You can leave this empty for now.  
    * This is a good time to prepare your file structure. In order to aid build processes later, make sure that all of your files are in the highest folder level possible. For example, if your project name was Testing Elm, your file structure should be set up like this:

      ```
      Testing Elm     
      - elm.package.json
      - YourProjectFile.elm
      - index.html
      - styles.css
      - Other Package Folders, etc.
      ```

    * In the Command Prompt, cd to your project folder. Enter

      `elm-make YourCapitalizedPortedFileName.elm --output elm.js`

      * This will generate elm.js based off of the information compiled from your elm file and index.html. The most important thing to note is that the styles.css file was included in this build process, and can be used in your elm file.

    * Enter `elm-reactor` to start the server using your project.

    * Instead of opening your elm file after opening localhost:8000, open the index.html file. This will incorporate the newly compiled elm.js, which includes both your elm project and the CSS file.

* Incorporating CSS, tips and tricks.

  * You can add css styling like normal in the CSS file. In order to reference the styles in the elm file, you add the class attribute to the brackets immediately following an element in the View definition. For example:
  ```elm
  button [class "my-class"] [ text "Click me"]
  ```

  * Adding element styles works like normal in the CSS file, so you can use the CSS file like normal.

* The Catch
  * Tldr: Guestimate and add class assignments in your elm file as you build the UI. That way, you won't have to rebuild the project every time you want to add or change a class in the elm file.
  
  * As alluded to earlier, the general approach for this method is to design as much of your UI as possible before adding the CSS. This is because elm-make will take a "snapshot" of your current elm files, and turn them into a regular Html project. This means that you will be able to manipulate the CSS as you like, but it will only take effect if you have already assigned the class name to the element in your elm file.

  * In order to work around this, there are two options:
    * Build out your UI as much as possible, attaching class names as you go. These can be defined in CSS later. When you run the elm-make command, you can tweak the CSS file and see the changes without having to rebuild the project.

    * Rebuild the project as needed. If you run the elm-make command from earlier, the elm file CSS assignments will be synced up with your current CSS folder. I do not recommend this, because it makes it tedious to add a class to an element, as opposed to just changing the CSS for an already assigned class.
