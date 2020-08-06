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
using neptune.compiler.macro.Utils;

enum ScopeItem
{
    SField(field :Field);
    SExpr(expr :Expr);
}

class Scope
{

    public function new() : Void
    {
        _scopeItems = new Map<String, ScopeItem>();
        _newScopeExprs = [];
    }

    public function addItem(name :String, item :ScopeItem) : Void
    {
        _scopeItems.set(name, item);
    }

    public function exists(name :String) : Bool
    {
        if(_scopeItems.exists(name)) {
            return true;
        }
        else if(_parentScope != null) {
            return _parentScope.exists(name);
        }
        else {
            return false;
        }
    }

    public function getItem(name :String) : Null<ScopeItem>
    {
        if(_scopeItems.exists(name)) {
            return _scopeItems.get(name);
        }
        else if(_parentScope != null) {
            return _parentScope.getItem(name);
        }
        else {
            return null;
        }
    }

    public function addScopedExpr(ident :String, initializer :Expr, updater :Expr) : Void
    {
        if(_scopeItems.exists(ident)) {
            if(!_newScopeExprs.exists(ident)) {
                _newScopeExprs.set(ident, []);
            }
            _newScopeExprs.get(ident).push({initializer: initializer, updater: updater});
        }
        else if(_parentScope != null) {
            _parentScope.addScopedExpr(ident, initializer, updater);
        }
        else {
            throw "err";
        }
    }

    public function insertScopedExprs(block :Array<Expr>) : Void
    {
        for(dep in _newScopeExprs.keyValueIterator()) {
            var ident = dep.key;
            var initUpdates = dep.value;
            var index = getExprIndex(ident, block);
            var updates :Array<Expr> = [];
            for(initUpdate in initUpdates) {
                block.insert(index++, initUpdate.initializer);
                updates.push(initUpdate.updater);
            }
            block.insert(index++, createSetter(ident, createUpdateFunc(updates)));
        }
    }

    public static function createSetter(ident :String, updateExpr :Expr) : Expr
    {
        var argName = 'new_${ident}';
        var assignmentExpr = OpAssign.createDefBinop(ident.createDefIdent().toExpr(), argName.createDefIdent().toExpr())
            .toExpr();

        var blockExpr = [assignmentExpr, updateExpr]
            .createDefBlock()
            .toExpr();

        return blockExpr.createDefFunc('set_${ident}', [argName])
            .toExpr();
    }

    private function createUpdateFunc(updates :Array<Expr>) : Expr
    {
        return [updates.createDefBlock().toExpr().createDefFuncAnon().toExpr()]
            .createDefCall("runUpdates")
            .toExpr();
    }

    private static function createSetterFn(name :String) : Function
    {
        var arg = {
            name: "val",
            opt: false,
            type: null,
            value: null,
            meta: null
        };

        var ident = name.substring(4).createDefIdent()
            .toExpr();
        var val = "val".createDefIdent()
            .toExpr();
        var binop = Binop.OpAssign.createDefBinop(ident, val)
            .toExpr();
        var returnExpr = ident.createDefReturn()
            .toExpr();

        var updateFunc = [name.createDefIdent().toExpr(), val]
            .createDefCall("updateTextNode")
            .toExpr();

        var block = [binop, updateFunc, returnExpr]
            .createDefBlock()
            .toExpr();

        return {
            args: [arg],
            ret: null,
            expr: block,
            params: []
        };
    }

    public function createChild() : Scope
    {
        var c = new Scope();
        c._parentScope = this;
        return c;
    }

    //wasteful
    private function getExprIndex(ident :String, block :Array<Expr>) : Int
    {
        var index = 1;
        for(item in block) {
            switch item.expr {
                case EVars(vars):
                    if(varsContainsIdent(ident, vars)) {
                        return index;
                    }
                case _:
            }
            index++;
        }

        return 0;
    }

    //wasteful
    private function varsContainsIdent(ident :String, vars :Array<Var>) : Bool
    {
        for(v in vars) {
            if(v.name == ident) {
                return true;
            }
        }
        return false;
    }

    private var _scopeItems :Map<String, ScopeItem>;
    private var _parentScope :Scope = null;
    private var _newScopeExprs :Map<String, Array<{initializer:Expr, updater:Expr}>>;
}
#end