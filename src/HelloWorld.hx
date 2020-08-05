import js.html.Node;
import neptune.platform.html.HtmlPlatform.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    public function new() : Void
    {
    }

    public function cool() : Node
    {
        var x = 0;
        var y = 0;
        function click() {
            x = x + 1;
            y = y - 2;
        }

        var markup = <Button onclick={click}>Update XY</Button>;

        return 
            <div class="taco">
                <h1>x: {x}</h1>
                <h1>y: {y}</h1>
                {markup}
            </div>;
    }
}