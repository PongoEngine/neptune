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
        var y = 0;
        var isX = true;
        function onClick() {
            x += 1;
            y -= 1;
            isX = !isX;
        }

        return 
            <div onclick={onClick}>{isX ? x : y}</div>;
    }
}