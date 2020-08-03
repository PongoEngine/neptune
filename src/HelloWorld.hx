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
        var tasty = 200;

        function a(nameA :String) {
            return function b(nameB :String) {
                var x = "Woah";
                return <div>{nameA} | {nameB} | {x}</div>;
            }
        }

        return a("Turtle")("Fred");
    }
}