package neptune.compiler.macro;

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
import neptune.util.Set;

class ExprDeps
{
    public var expr :Expr;

    public function new(expr :Expr, deps :Array<String>) : Void
    {
        this.expr = expr;
        _deps = new Set<String>();
        for(dep in deps) {
            this.addDep(dep);
        }
    }

    public inline function addDep(name :String) : Void
    {
        _deps.set(name);
    }

    public inline function removeDep(name :String) : Void
    {
        _deps.remove(name);
    }

    public inline function existsDep(name :String) : Bool
    {
        return _deps.exists(name);
    }

    public inline function isSatisfied() : Bool
    {
        return _deps.length == 0;
    }

    private var _deps :Set<String>;
}

#end