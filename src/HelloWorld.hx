import js.html.Node;
import neptune.platform.html.HtmlPlatform.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    public var name = "Neptune";

    public function new() : Void
    {
    }

    public function cool() : Node
    {
        var x = 0;
        var y = 0;
        var q = 3;
        function click() {
            x = x + 1 + q;
            y = y - 2;
            this.name = "Sage";
        }

        var markup = <Button onclick={click}>Update XY</Button>;

        return 
            <div class="taco">
                <h1>x: {x}</h1>
                <h2>y: {y}</h2>
                <h3>name: {name}</h3>
                {markup}
            </div>;
    }
}