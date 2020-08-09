import js.html.Node;
import neptune.platform.html.HtmlPlatform.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    
    public function new() : Void
    {
    }

    public function template() : Node
    {
        var x = 30;
        var isLeft = true;
        function incrementX() {
            x = x + 1;
        }
        function toggleIsLeft() {
            isLeft = !isLeft;
        }

        var left = <h1>Left</h1>;
        var right = <h1>Right</h1>;

        return 
            <div>
                <button onclick={incrementX}>Increment X</button>
                <h2>{x}</h2>
                <button onclick={toggleIsLeft}>Toggle IsLeft</button>
                {isLeft ? left : right}
            </div>;
    }
}