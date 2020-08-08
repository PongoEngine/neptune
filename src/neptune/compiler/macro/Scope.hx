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

import neptune.compiler.dom.Parser.DomAST;
#if macro
import haxe.macro.Expr;
using neptune.compiler.macro.ExprUtils;

class Scope
{
    public function new(block :Array<Expr>) : Void
    {
        _block = block;
    }

    public function createChild(block :Array<Expr>) : Scope
    {
        var c = new Scope(block);
        c._parent = this;
        return c;
    }

    public function addAssignment(expr :Expr) : Void
    {
        expr.print();
    }

    // public function saveDom(dom :DomAST) : Void
    // {
    //     _dom = dom;
    // }

    public function run(dom :DomAST) : ExprDef
    {
        return CompileDom.handleTree(this, dom).expr;
    }

    private var _parent :Scope;
    private var _block :Array<Expr>;
}

#end