import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    // public var robot (default, null):Int = 1;
    public var numba :Int = 1;
    public var ten :Int = 1;
    public var hai :String = "Hai";
    public var isCool = false;

    public function handleClick() 
    {
        numba += 1;
    }

    public function changeText() 
    {
        hai = "Carla";
        this.isCool = !this.isCool;
    }

    public function template() : Element
    {
        // var taccccooo = <h1>Taco bout it?</h1>;
        // var r= 0;

        // // var x : = 3;
        // var robot :Int = 1;
        var x = 3;

        function set_x(val) {
            x = val;
            trace(x);
        }

        set_x(1000);


        return 
            <div>
                <h2>{(numba + ten) * 200} - {hai}</h2>
                <h3>{isCool ? "sausage" : "turkey"}</h3>
                <button class="button" onclick={handleClick}>Increment</button>
                <button onclick={changeText}>Say Hello</button>
            </div>;
    }
}