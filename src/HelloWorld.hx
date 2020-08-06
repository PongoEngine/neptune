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
        var x = 0;
        var y = 0;
        var textValue = "sage";
        var isX = false;
        function incrementX() {
            x = x + 1;
        }

        function incrementY() {
            y = y + 1;
        }

        function flipIsX() {
            isX = !isX;
        }

        var m3 = <button>{x}</button>;
        var markup1 = <button onclick={incrementX}>Update X {x},{y}</button>;
        var markup2= <button onclick={flipIsX}>Flip X</button>;
        var markup3= <p>{ isX ? x : y }</p>;

        return 
            <div class="taco">
                <h1>x: {x}</h1>
                <h2>y: {y}</h2>
                {markup1}
                {markup2}
                {markup3}
                <p>{textValue}</p>
            </div>;
    }
}