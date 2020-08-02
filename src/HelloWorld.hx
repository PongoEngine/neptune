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

        function cool() {
            trace("sup!");
            return <h1>Hello</h1>;
        }


        // return <h1 onclick={changeX}>{x}{y}{z}{"helssslo"}</h1>;

        return "taco";
    }
}