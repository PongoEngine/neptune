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
        function click() {
            x += 1;
        }

        return <h1 class="taco" onclick={click}>Number {x}</h1>;
    }
}