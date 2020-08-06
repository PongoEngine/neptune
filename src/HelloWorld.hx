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
        var right = <h4>right</h4>;

        function onClick() {
            isLeft = !isLeft;
            x = x + 1;
        }

        return 
            <div onclick={onClick}>
                {isLeft ? left : right}
                <h1>{x}</h1>
            </div>;
    }
}