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
        var x = 20;
        function onClick() {
            x += 1;
            trace(x);
        }

        return 
            <div onclick={onClick}>Hello2 {x}</div>;
    }
}