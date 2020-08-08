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
import neptune.compiler.dom.Parser.DomAST;
using neptune.compiler.macro.ExprUtils;
using neptune.compiler.macro.scope.ScopeUtil;
using neptune.compiler.macro.Assignment;

class BlockScope implements Scope
{
    public var parent :Scope;

    public function new(block :Array<Expr>) : Void
    {
        _block = block;
        _assignments = [];
        _updates = [];
    }

    public function createChild(block :Array<Expr>) : Scope
    {
        var c = new BlockScope(block);
        c.parent = this;
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

    public inline function addAssignment(expr :Expr) : Void
    {
        _assignments.push(expr.saveAssignment());
    }

    public function run(dom :DomAST) : ExprDef
    {
        return CompileDom.handleTree(this, dom).expr;
    }

    public function completeBlock() : Void
    {
        for(assignment in _assignments) {
            var index = assignment.deps.getInsertIndex(_block);
            var setter = assignment.createSetter();
            setter.print();
        }
    }

    private var _block :Array<Expr>;
    private var _updates :Array<{expr :Expr, deps :Array<String>}>;
    private var _assignments :Array<Assignment>;
}

#end