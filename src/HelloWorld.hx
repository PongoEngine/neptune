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
        function onClick() {
            x = x + 1;
        }

        function onClickY() {
            y = y + 1;
        }

        var m3 = <button>{x}</button>;
        var markup1 = <button onclick={onClick}>Update X {x},{y}</button>;
        var markup2 = <button onclick={onClickY}>Update Y {x},{y}</button>;

        return 
            <div class="taco">
                <h1>x: {x}</h1>
                <h2>y: {y}</h2>
                {markup1}
                {markup2}
                <p>{textValue}</p>
            </div>;
    }
}