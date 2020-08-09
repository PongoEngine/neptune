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
        function onClick() {
            x = x + 1;
        }

        var left = <h1>Left</h1>;
        var right = <h1>Right</h1>;

        return 
            <div onclick={onClick}>
                <h2>{x}</h2>
            </div>;
    }
}