package ;

/*
 * Copyright (c) 2022 Jeremy Meltingtallow
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import js.html.Node;
import neptune.Neptune;

class Expressions implements Neptune
{
    
    public function new() : Void
    {
    }

    public function garbage() : Node
    {
        return
            <div>Hello</div>;        
    }

    public function template() : Node
    {
        var x = 12033;

        function onClick() {
            x += 1;
            trace(x);
        }

        return 
            <div>
                <button id="hello" @click={onClick;}>Increment</button>
                {
                    var q = x + 22;
                    {<div>HelloYouPerson + 22 {x + q;}</div>}
                }
                <h2>Length - {x + 45;}</h2>
            </div>;
    }
}