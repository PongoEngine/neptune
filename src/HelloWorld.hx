import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    public function new() : Void
    {
    }


    public function template() : String
    {
        var hello = "Hi";
        return <h1>{hello}</h1>;
    }
}