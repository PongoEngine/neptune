package roadmap;

/*
 * Copyright (c) 2020 Jeremy Meltingtallow
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
import neptune.platform.html.HtmlPlatform.*;
import neptune.Neptune;

class RoadMap implements Neptune 
{
    
    public function new() : Void
    {
    }

    public function template() : Node
    {
        var x = 30;
        var isLeft = true;
        function incrementX() {
            x = x + 1;
        }

        var left = <h1>Left</h1>;
        var right = <h1>Right</h1>;

        function toggleIsLeft() {
            isLeft = !isLeft;
        }

        return 
            <div>
                <button onclick={incrementX}>Increment X</button>
                <h2>{x}</h2>
                <button onclick={toggleIsLeft}>Toggle IsLeft</button>
                {isLeft ? left : right}
            </div>;
    }
}