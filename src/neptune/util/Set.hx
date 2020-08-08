package neptune.util;

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

class Set<T:{}>
{
    public var length :Int;

    public function new() : Void
    {
        _map = new Map<T, Bool>();
        this.length = 0;
    }

    public function iterator() : Iterator<T>
    {
        return _map.keys();
    }

    public function set(item :T) : Void
    {
        if(!_map.exists(item)) {
            this.length++;
        }
        _map.set(item, true);
    }

    public function remove(item :T) : Void
    {
        if(!_map.exists(item)) {
            throw "err";
        }
        this.length--;
        _map.remove(item);
    }

    public function exists(item :T) : Bool
    {
        return _map.exists(item);
    }

    private var _map :Map<T, Bool>;
}