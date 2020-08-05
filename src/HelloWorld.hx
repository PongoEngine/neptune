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
        var ythis = 0;
        var x = 0;
        var y = 0;
        function click() {
            x = x + 1;
            y = x - 1;
        }

        var markup = <span>Taco</span>;

        return 
        <h1 class="taco" onclick={click}>
            Number {x} {y}
            {markup}
        </h1>;
    }
}