import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    var hello = "Hi";
    var giibye = "woah";


    public function new() : Void
    {
    }


    public function template() : String
    {
        var robot = 2;
        var x = 0.3;
        var carla = <p>woah</p>;

        function cool() {
            return <h1>{carla}</h1>;
        }

        function water() {
            var neptune = <p>woah</p>;
            return <h1>{carla}</h1>;
        }

        trace(robot);

        return <h1 onclick={changeX}>{x}{y}{z}{hello}</h1>;
    }
}