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
            x = x + 1;
        }

        return 
            <div onclick={onClick}>{x}</div>;
    }
}