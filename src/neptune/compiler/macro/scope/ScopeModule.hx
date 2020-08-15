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
import neptune.util.Set;
using neptune.compiler.macro.ExprUtils;

class ScopeModule implements Scope
{
    public var parent :Scope;
    public var children :Array<Scope>;

    public function new(fields :Array<Field>) : Void
    {
        this.children = [];
        _fields = fields;
    }

    public function createChild(block :Array<Expr>) : Scope
    {
        var c = new ScopeBlock(block);
        c.parent = this;
        this.children.push(c);
        return c;
    }

    public function runThrough(fn :Scope -> Void) : Void
    {
        for(c in children) {
            c.runThrough(fn);
        }
        fn(this);
    }


    public function saveVar(var_ :Var) : Void
    {
        throw "err";
    }

    public function getVar(name :String) : Var
    {
        throw "err";
    }

    public function addVarExpr(expr :Expr) : Void
    {
        throw "err";
    }

    public function addUpdateExpr(expr :Expr) : Void
    {
        throw "err";
    }

    public inline function transformAssignment(expr :Expr) : Void
    {
        throw "err";
    }

    public function updateBlock() : Void
    {
    }

    public function pushAssignments(?assignments :Set<String>) : Void
    {
    }

    private var _fields :Array<Field>;
}

#end