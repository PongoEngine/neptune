import js.html.Element;
import neptune.lib.Runtime.*;
import neptune.Neptune;

class Magic implements Neptune 
{
    public var turkey :String = "Turkey";
    
    public function template() : Element
    {
        return <p>{turkey}</p>;
    }
}