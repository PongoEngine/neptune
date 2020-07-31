import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class HelloWorld implements Neptune 
{
    public var numba :Int = 1;
    public var ten :Int = 10;
    public var hai :String = "Hi";
    
    public function handleClick() 
    {
        numba += 1;
    }

    public function template() : Element
    {
        return 
            <div>
                <h2>{numba} - {hai}</h2>
                <button class="button" onclick={handleClick}>Increment</button>
            </div>;
    }
}