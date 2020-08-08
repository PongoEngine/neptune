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
                addDeps(var_.expr, deps);
                var expr = EVars([var_]).toExpr();
                _newExprs.push(new ExprDeps(expr, deps));
            }
            case _: throw "err";
        }
    }

    //The goal here is to remove the need for ident
    public function addSetter(ident :String, expr :Expr) : Void
    {
        switch expr.expr {
            case ECall(e, params): 
                var deps = [];
                for(param in params) {
                    addDeps(param, deps);
                }
                // _newExprs.push({expr: createSetter(ident, expr), deps: deps});
                _newExprs.push(new ExprDeps(createSetter(ident, expr), deps));
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
    private function insertIntoBlock(setter :ExprDeps) : Void
    {
        var index = 0;
        for(blockItem in _block) {
            switch blockItem.expr {
                case EVars(vars): for(var_ in vars) {
                    setter.removeDep(var_.name);
                }
                case _:
            }
            index++;
            if(setter.isSatisfied()) {
                _block.insert(index, setter.expr);
                return;
            }
        }
    }

    private function addDeps(expr :Expr, deps :Array<String>) : Void
    {
        switch expr.expr {
            case EConst(c): switch c {
                case CIdent(s): deps.push(s);
                case _: throw "not implemented yet";
            }
            case ECall(e, params):
                for(param in params) {
                    addDeps(param, deps);
                }
            case _:
                throw "not implemented yet";
        }
    }

    private function createSetter(ident :String, updateExpr :Expr) : Expr
    {
        var argName = 'new_${ident}';
        var assignmentExpr = OpAssign.createDefBinop(ident.createDefIdent().toExpr(), argName.createDefIdent().toExpr())
            .toExpr();

        return [assignmentExpr, updateExpr]
            .createDefBlock()
            .toExpr()
            .createDefFunc('set_${ident}', [argName])
            .toExpr();
    }

    private var _parentScope :Scope = null;
    private var _scopeExprs : Map<String, Bool>;
    private var _newExprs :Array<ExprDeps>;
    private var _block :Array<Expr>;
}

class ExprDeps
{
    public var expr :Expr;

    public function new(expr :Expr, deps :Array<String>) : Void
    {
        this.expr = expr;
        _deps = new Map<String, Bool>();
        _length = 0;
        for(dep in deps) {
            this.addDep(dep);
        }
    }

    public function addDep(name :String) : Void
    {
        if(_deps.exists(name)) {
            throw "err";
        }
        _deps.set(name, true);
        _length++;
    }

    public function removeDep(name :String) : Void
    {
        // if(!_deps.exists(name)) {
        //     throw "err";
        // }
        // _deps.remove(name);
        // _length--;
        if(_deps.remove(name)) {
            _length--;
        }
    }

    public function isSatisfied() : Bool
    {
        return _length == 0;
    }

    private var _deps :Map<String, Bool>;
    private var _length :Int;
}

#end