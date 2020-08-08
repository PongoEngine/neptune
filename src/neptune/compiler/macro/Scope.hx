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
                addDeps(var_.expr, deps);
                var expr = EVars([var_]).toExpr();
                _newExprs.push({expr: expr, deps: deps});
            }
            case _: throw "err";
        }
    }

    //The goal here is to remove the need for ident
    public function addSetter(ident :String, expr :Expr) : Void
    {
        var deps = [];
        switch expr.expr {
            case ECall(e, params): 
                for(param in params) {
                    addDeps(param, deps);
                }
            case _: 
                throw "err";
        }
        
        _newExprs.push({expr: createSetter(ident, expr), deps: deps});
    }

    public function insertScopedExprs() : Void
    {
        for(expr in _newExprs) {
            insertIntoBlock(expr);
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

    //TODO: does not take scope into account. Will need to work on this.
    private function insertIntoBlock(setter :{expr:Expr, deps :Array<String>}) : Void
    {
        var index = 0;
        for(blockItem in _block) {
            switch blockItem.expr {
                case EVars(vars): for(var_ in vars) {
                    setter.deps.remove(var_.name);
                }
                case _:
            }
            index++;
            if(setter.deps.length == 0) {
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
    private var _newExprs :Array<{expr:Expr, deps :Array<String>}>;
    private var _block :Array<Expr>;
}
#end