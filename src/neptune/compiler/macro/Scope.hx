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

import haxe.macro.Context;
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
        _items = new Map<String, ScopeItem>();
        _newExprs = [];
    }

    public function addItem(name :String, item :ScopeItem) : Void
    {
        _items.set(name, item);
    }

    public function exists(name :String) : Bool
    {
        if(_items.exists(name)) {
            return true;
        }
        else if(_parent != null) {
            return _parent.exists(name);
        }
        else {
            return false;
        }
    }

    public function getItem(name :String) : Null<ScopeItem>
    {
        if(_items.exists(name)) {
            return _items.get(name);
        }
        else if(_parent != null) {
            return _parent.getItem(name);
        }
        else {
            return null;
        }
    }

    public function addScopedExpr(ident :String, expr :Expr) : Void
    {
        if(_items.exists(ident)) {
            if(!_newExprs.exists(ident)) {
                _newExprs.set(ident, []);
            }
            _newExprs.get(ident).push(expr);
        }
        else if(_parent != null) {
            _parent.addScopedExpr(ident, expr);
        }
        else {
            throw "err";
        }
    }

    public function insertScopedExprs(block :Array<Expr>) : Void
    {
        for(dep in _newExprs.keyValueIterator()) {
            var ident = dep.key;
            var exprs = dep.value;
            var index = getExprIndex(ident, block);
            for(expr in exprs) {
                block.insert(index++, expr);
            }
            block.insert(index++, Setter.createSetter(ident));
        }
    }

    //super hacky
    public function updateFields(fields :Array<Field>) : Array<Field>
    {
        var newFields = [];
        for(dep in _newExprs.keyValueIterator()) {
            var ident = dep.key;
            var exprs = dep.value;
            for(expr in exprs) {
                switch expr.expr {
                    case EVars(vars):
                        for(var_ in vars) {
                            newFields.push({
                                name: var_.name,
                                doc: null,
                                access: [APublic],
                                kind: FVar(macro: Dynamic, null),
                                pos: Context.currentPos(),
                                meta: null,
                            });
                            for(f in fields) {
                                if(f.name == var_.name.substr(4)) {
                                    switch f.kind {
                                        case FVar(t, e):
                                            f.kind = FProp("default", "set", t, e);
                                        case _:
                                            throw "not implemented yet";
                                    }
                                }
                            }
                            newFields.push({
                                name: 'set_${var_.name.substr(4)}',
                                doc: null,
                                access: [APrivate],
                                kind: FFun(createSetterFn(var_.name)),
                                pos: Context.currentPos(),
                                meta: null,
                            });
                        } 
                    case _:
                        throw "not implemented yet";
                }
            }
        }
        return newFields;
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

    public function createFieldInitializers() : Array<{name :String, expr :Expr}>
    {
        var initializers = [];
        for(dep in _newExprs.keyValueIterator()) {
            var ident = dep.key;
            var exprs = dep.value;
            for(expr in exprs) {
                switch expr.expr {
                    case EVars(vars):
                        for(initializer in vars) {
                            initializers.push({name: initializer.name, expr: initializer.expr});
                        } 
                    case _:
                        throw "not implemented yet";
                }
            }
        }
        return initializers;
    }

    public function createChild() : Scope
    {
        var c = new Scope();
        c._parent = this;
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

    private var _items :Map<String, ScopeItem>;
    private var _parent :Scope = null;
    private var _newExprs :Map<String, Array<Expr>>;
}
#end