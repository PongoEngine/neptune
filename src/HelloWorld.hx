import js.html.Node;
import neptune.platform.html.HtmlPlatform.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    var hello = "Hello";
    var gf = "Carla";
    var hungry = "All the time";
    var helper = 101;
    var isYes = true;

    var x = <span>Hi</span>;

    public function new() : Void
    {
    }

    public function template() : Node
    {
        var tasty = 100;
        tasty += 20 - helper;
        return 
            <div>{tasty}</div>;
    }
}