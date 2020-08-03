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

        var x = "Woah";

        function func1(road :String) {
            var a = <h2>Coo</h2>;
            return <h1>{road}</h1>;
        }


        return func1("turtle");
    }
}