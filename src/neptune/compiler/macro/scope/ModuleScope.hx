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
using neptune.compiler.macro.scope.ScopeUtil;

class ModuleScope implements Scope
{
    public var parent :Scope;

    public function new(fields :Array<Field>) : Void
    {
        _fields = fields;
    }

    public function createChild(block :Array<Expr>) : Scope
    {
        var c = new BlockScope(block);
        c.parent = this;
        return c;
    }

    public function addVar(expr :Expr) : Void
    {
        throw "err";
    }

    public function addUpdate(expr :Expr) : Void
    {
        throw "err";
    }

    public inline function addAssignment(expr :Expr) : Void
    {
        throw "err";
    }

    public function complete() : Void
    {

    }

    private function addSetter(setter :{dep :String, expr :Expr}) : Void
    {
        throw "err";
    }

    private var _fields :Array<Field>;
}

#end