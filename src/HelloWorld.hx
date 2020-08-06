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
        function onClick() {
            isLeft = !isLeft;
        }
        // var left = <p>left</p>;
        // var right = <p>right</p>;

        return 
            <div onclick={onClick}>
                {isLeft ? 0 : 1}
            </div>;
    }
}