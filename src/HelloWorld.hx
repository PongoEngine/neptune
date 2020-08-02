import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    public function new() : Void
    {
        var x = <h1>Hi2</h1>;
    }


    public function template() : String
    {
        var x :Int = cast [<h1>Hi2</h1>, <h1>Hi3</h1>];
        var r = <h4>hsfd</h4>;
        r = <h1>cool</h1>;

        var r = <h1>sdf</h1>;
        try {
            <h3>dfs</h3>;
        }
        catch(e) {
            <h3>dfs</h3>;
        }

        var x = switch true {
            case true: <h1>Hi2</h1>;
            case false: <h1>Hi2</h1>;
        }

        var x = if(true) <h1>Hi2</h1> else (<h1>Hi2</h1>);
        // var x = true ? <h1>Hi2</h1> : <h1>totes</h1>;
        return untyped x[1];
    }
}