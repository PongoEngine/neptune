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
using neptune.compiler.macro.ExprUtils;

class Scope
{
    public function new(block :Array<Expr>) : Void
    {
        _scopeExprs = new Map<String, Bool>();
        _newExprs = [];
        _block = block;
    }

    public function addScopedItem(name :String, isMarkup :Bool) : Void
    {
        _scopeExprs.set(name, isMarkup);
    }

    public function addInitializer(expr :Expr) : Void
    {
        switch expr.expr {
            case EVars(vars): for(var_ in vars) {
                var deps = [];
                ScopeUtil.addDeps(var_.expr, deps);
                var expr = EVars([var_]).toExpr();
                _newExprs.push(new ExprDeps(expr, deps));
            }
            case _: 
                throw "err";
        }
    }

    //The goal here is to remove the need for ident
    public function addSetter(ident :String, expr :Expr) : Void
    {
        switch expr.expr {
            case ECall(e, params): 
                var deps = [];
                for(param in params) {
                    ScopeUtil.addDeps(param, deps);
                }
                _newExprs.push(new ExprDeps(ScopeUtil.createSetter(ident, expr), deps));
            case _: 
                throw "err";
        }
    }

    public function createChild(block :Array<Expr>) : Scope
    {
        var c = new Scope(block);
        c._parentScope = this;
        return c;
    }

    public function isMeta(name :String) : Bool
    {
        if(_scopeExprs.exists(name)) {
            return _scopeExprs.get(name);
        }
        else if(_parentScope != null) {
            return _parentScope.isMeta(name);
        }
        else {
            throw "err";
        }
    }

    public function insertScopedExprs() : Void
    {
        for(expr in _newExprs) {
            insertIntoBlock(expr);
        }
    }

    //TODO: does not take scope into account. Will need to work on this.
    private function insertIntoBlock(newExpr :ExprDeps) : Void
    {
        var index = ScopeUtil.getInsertIndex(newExpr, _block);
        if(index != -1) {
            _block.insert(index, newExpr.expr);
        }
        else {
            _parentScope.insertIntoBlock(newExpr);
        }
    }

    private var _parentScope :Scope = null;
    private var _scopeExprs : Map<String, Bool>;
    private var _newExprs :Array<ExprDeps>;
    private var _block :Array<Expr>;
}

#end