app "squares"
    packages { ray: "https://github.com/lukewilliamboswell/roc-ray/releases/download/test/5JjXlOa8wScAnwM6Dl2LaHAygvRbZ_bXgaonv1z8xes.tar.br" }
    imports [ray.Task.{ Task }, ray.Core.{ Color, Rectangle }]
    provides [main, Model] to ray

Program : {
    init : Task Model [],
    render : Model -> Task Model [],
}

Model : {
    squares : List Rectangle,
    status : [Ready, AfterClick Core.Vector2],
}

main : Program
main = { init, render }

width = 800
height = 600

init : Task Model []
init =

    {} <- Core.setWindowSize { width, height } |> Task.await
    {} <- Core.setWindowTitle "Squares Demo" |> Task.await

    Task.ok { squares: [], status: Ready }

render : Model -> Task Model []
render = \model ->

    {} <- Core.drawText { text: "Click on the screen to draw a square", posX: width - 400, posY: height - 25, fontSize: 20, color: white } |> Task.await

    { x, y } <- Core.getMousePosition |> Task.await
    isMousePressed <- Core.isMouseButtonPressed LEFT |> Task.await

    mouseX = x |> Num.round |> Num.toStr
    mouseY = y |> Num.round |> Num.toStr

    {} <- Core.drawText {
            text: "Mouse $(mouseX),$(mouseY)",
            posX: 10,
            posY: height - 25,
            fontSize: 20,
            color: white,
        }
        |> Task.await

    # Draw the squares
    {} <- drawSquares model.squares |> Task.await

    when model.status is
        Ready ->
            if isMousePressed then
                Task.ok { model & status: AfterClick { x, y } }
            else
                Task.ok model

        AfterClick start ->
            new = {
                x: if start.x < x then start.x else x,
                y: if start.y < y then start.y else y,
                width: Num.absDiff start.x x,
                height: Num.absDiff start.y y,
            }

            if isMousePressed then
                Task.ok { model & status: Ready, squares: List.append model.squares new }
            else
                # Draw the in-progress sqaure, but don't update the model
                {} <- Core.drawRectangle {
                        x: new.x,
                        y: new.y,
                        width: new.width,
                        height: new.height,
                        color: green,
                    }
                    |> Task.await

                Task.ok model

drawSquares : List Rectangle -> Task {} []
drawSquares = \squares ->
    List.walk squares (Task.ok {}) \state, bounds ->
        state
        |> Task.await \{} ->
            Core.drawRectangle {
                x: bounds.x,
                y: bounds.y,
                width: bounds.width,
                height: bounds.height,
                color: white,
            }

# === HELPERS ========================

green = { r: 0, g: 255, b: 0, a: 255 }
white = { r: 255, g: 255, b: 255, a: 255 }
