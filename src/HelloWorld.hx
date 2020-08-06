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
        var left = <h2>left</h2>;

        function updateX() {
            x = x + 1;
        }

        var right = <h4 onclick={updateX}>right {x}</h4>;

        function onClick() {
            isLeft = !isLeft;
        }

        return 
            <div>
                {isLeft ? left : right}
                <h1 onclick={onClick}>{x}</h1>
            </div>;
    }
}