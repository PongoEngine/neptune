import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    var hello = "Hi";
    public function new() : Void
    {
    }


    public function template() : String
    {
        var x = 2, y = 5, z = 3;
        function changeX() {
            x += 1;
        }
        return <h1 onclick={changeX}>{x}{y}{z}{"hello"}</h1>;
    }
}