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

class BlockScope implements Scope
{
    public var parent :Scope;

    public function new(block :Array<Expr>) : Void
    {
        _block = block;
        _assignments = [];
        _updates = [];
        _setters = new Map<String, {expr: Expr -> Expr, dep :String, updates :Array<Expr>}>();
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
            case EVars(vars):
                if(vars.length != 1) throw "err";
                var deps = [].findDeps(vars[0].expr);
                var index = deps.getInsertIndex(_block);
                _block.insert(index, expr);
            case _:
                throw "impossible";
        }
    }

    /**
     * Raw dom update that needs to be called when dependency is updated.
     * @param expr 
     */
    public function addUpdate(expr :Expr, dep :Expr) : Void
    {
        _updates.push({expr: expr, dep: dep});
    }

    public inline function addAssignment(expr :Expr) : Void
    {
        _assignments.push(expr);

    }

    public function prepSetters() : Void
    {
        var setters = new Map<String, {dep :String, expr :Expr -> Expr}>();
        for(assignment in _assignments) {
            AssignmentUtil.create(assignment, setters);
        }
        for(s in setters) {
            prepSetter(s);
        }
    }

    public function completeSetters() : Void
    {
        for(update in _updates) {
            switch update.dep.expr {
                case EConst(c): switch c {
                    case CIdent(s):
                        _setters.get(s).updates.push(update.expr);
                    case _:
                        throw "not implemented yet";
                }
                case _:
                    throw "not implemented yet";
            }
        }

        for(setter in _setters) {
            var index = [setter.dep].getInsertIndex(_block);
            var updateExpr = setter.updates.createDefArrayDecl().toExpr();
            _block.insert(index, setter.expr(updateExpr));
        }
    }

    private function prepSetter(setter :{dep :String, expr :Expr -> Expr}) : Void
    {
        var index = [setter.dep].getInsertIndex(_block);
        if(index == -1) {
            this.parent.prepSetter(setter);
        }
        else {
            if(_setters.exists(setter.dep)) {
                throw "already exists setter!";
            }
            _setters.set(setter.dep, {expr: setter.expr, dep: setter.dep, updates: []});
        }
    }

    private var _block :Array<Expr>;
    private var _assignments :Array<Expr>;
    private var _updates :Array<{expr :Expr ,dep :Expr}>;

    private var _setters :Map<String, {expr: Expr -> Expr, dep :String, updates :Array<Expr>}>;
}

#end