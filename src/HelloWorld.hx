import js.html.Node;
import neptune.platform.html.HtmlPlatform.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    
    public function new() : Void
    {
    }

    public function cool() : Node
    {
        var isLeft = true;
        var x = 0;
        var y = 0;
        var left = <h2>This is a heading</h2>;

        function updateX() {
            x = x + 1;
            y = y - 1;
        }

        var right = <div><button onclick={updateX}>Increment X</button></div>;

        function nestedFunc() {
            return <h1>Hi</h1>;
        }

        function onClick() {
            isLeft = !isLeft;
        }

        return 
            <div>
                <button onclick={onClick}>Toggle Child</button>
                {isLeft ? left : right}
                <h1>{x} {y}</h1>
                {nestedFunc()}
            </div>;
    }

    //this is just a quick stub for styles
    //future plans are to scope styles to module
    var style =
        <style>
            html, body {
                text-align: center;
                margin: 0;
            }
            button {
                color : #ff0000;
            }
        </style>
}