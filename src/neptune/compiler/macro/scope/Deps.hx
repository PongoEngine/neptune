package neptune.compiler.macro.scope;

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

#if macro
import haxe.macro.Expr;
using neptune.compiler.macro.ExprUtils;
using neptune.compiler.macro.scope.DepsUtil;

class Deps
{
    public function new() : Void
    {
        _map = new Map<String, Bool>();
        _length = 0;
    }

    public function iterator() : Iterator<String>
    {
        return _map.keys();
    }

    public function set(item :String) : Void
    {
        if(!_map.exists(item)) {
            _length++;
        }
        _map.set(item, true);
    }

    public function remove(item :String) : Void
    {
        if(_map.exists(item)) {
            _length--;
        }
        _map.remove(item);
    }

    public function isSatisfied() : Bool
    {
        return _length == 0;
    }

    public function toString() : String
    {
        var deps = [];
        for(item in _map.keys()) {
            deps.push(item);
        }
        return deps.toString();
    }

    public static function from(expr :Expr) : Deps
    {
        var deps = new Deps();
        return deps.findDeps(expr);
    }

    private var _map :Map<String, Bool>;
    private var _length :Int;
}

#end