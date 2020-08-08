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
        var name = "Jeremy";

        function subTemplate() {
            return <h2>{name}</h2>;
        }

        return 
            <div>Hello {name}</div>;
    }
}