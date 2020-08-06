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
using neptune.compiler.macro.ScopeUtils;

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
            var updates :Array<Expr> = [];
            for(initUpdate in initUpdates) {
                block.pushExpr(initUpdate.initializer);
                updates.push(initUpdate.updater);
            }
            var setter = createSetter(ident, createUpdateFunc(updates));
            var placeholder = ExprUtils.createDefFuncAnon(ExprUtils.createDefBlock([]).toExpr(), ["val"]).toExpr()
                .createDefVar(setter.name)
                .toExpr();
                
            block.unshift(placeholder);
            block.pushExpr(setter.expr);
        }
    }

    public static function createSetter(ident :String, updateExpr :Expr) : {name :String, expr :Expr}
    {
        var argName = 'new_${ident}';
        var assignmentExpr = OpAssign.createDefBinop(ident.createDefIdent().toExpr(), argName.createDefIdent().toExpr())
            .toExpr();

        var blockExpr = [assignmentExpr, updateExpr]
            .createDefBlock()
            .toExpr();

        var name = 'set_${ident}';
        var anon = blockExpr.createDefFuncAnon([argName])
            .toExpr();
        var expr = Binop.OpAssign.createDefBinop(name.createDefIdent().toExpr(), anon)
            .toExpr();
            
        return {name: name, expr: expr};
    }

    private function createUpdateFunc(updates :Array<Expr>) : Expr
    {
        return [updates.createDefBlock().toExpr().createDefFuncAnon([]).toExpr()]
            .createDefCall("runUpdates")
            .toExpr();
    }

    public function createChild() : Scope
    {
        var c = new Scope();
        c._parentScope = this;
        return c;
    }

    private var _scopeItems :Map<String, ScopeItem>;
    private var _parentScope :Scope = null;
    private var _newScopeExprs :Map<String, Array<{initializer:Expr, updater:Expr}>>;
}
#end