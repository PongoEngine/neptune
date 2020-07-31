import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
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
        // var e = <h1>Hello</h1>;

        var s = new Sage();
        return 
            <div>
                {<h6>This is some good stuff</h6>}
                <h2>{(numba + ten) * 200} - {hai}</h2>
                <h3>{isCool ? "sausage" : "turkey"}</h3>
                <h4>{s.template()}</h4>
                <button class="button" onclick={handleClick}>Increment</button>
                <button onclick={changeText}>Say Hello</button>
            </div>;
    }
}

class Sage implements Neptune 
{
    public var flavor :Int = 9999;

    public function template() : Element
    {
        return <h2>{flavor}</h2>;
    }
}