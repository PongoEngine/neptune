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
import neptune.compiler.dom.Parser.DomAST;
using neptune.compiler.macro.ExprUtils;
using neptune.compiler.macro.ScopeUtil;
using neptune.compiler.macro.Assignment;

class Scope
{
    public function new(block :Array<Expr>) : Void
    {
        _block = block;
        _children = [];
        _assignments = [];
        _updates = [];
    }

    public function createChild(block :Array<Expr>) : Scope
    {
        var c = new Scope(block);
        c._parent = this;
        _children.push(c);
        return c;
    }

    public function addVar(expr :Expr) : Void
    {
        switch expr.expr {
            case EVars(vars): for(var_ in vars) {
                var deps = [].findDeps(var_.expr);
                var index = deps.getInsertIndex(_block);
                _block.insert(index, expr);
            }
            case _:
                throw "impossible";
        }
    }

    public function addUpdate(expr :Expr) : Void
    {
        switch expr.expr {
            case ECall(e, params): 
                var deps = [];
                for(param in params) {
                    deps.findDeps(param);
                }
                _updates.push({expr: expr, deps: deps});
            case _:
                throw "impossible";
        }
    }

    public function addAssignment(expr :Expr) : Void
    {
        var assignment = expr.saveAssignment();
        _assignments.push(assignment);
    }

    public function run(dom :DomAST) : ExprDef
    {
        return CompileDom.handleTree(this, dom).expr;
    }

    public function completeBlock() : Void
    {
        // trace(_assignments.length, _updates.length);

        for(c in _children) {
            c.completeBlock();
        }
    }

    private var _parent :Scope;
    private var _children :Array<Scope>;

    private var _block :Array<Expr>;
    private var _updates :Array<{expr :Expr, deps :Array<String>}>;
    private var _assignments :Array<Assignment>;
}

#end