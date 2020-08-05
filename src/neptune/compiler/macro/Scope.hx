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

import haxe.macro.Expr;

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
            var index = getIndex(ident, block);
            for(expr in exprs) {
                block.insert(index++, expr);
            }
        }
    }

    //wasteful
    public function getIndex(ident :String, block :Array<Expr>) : Int
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
    public function varsContainsIdent(ident :String, vars :Array<Var>) : Bool
    {
        for(v in vars) {
            if(v.name == ident) {
                return true;
            }
        }
        return false;
    }

    public function createChild() : Scope
    {
        var c = new Scope();
        c._parent = this;
        return c;
    }

    private var _items :Map<String, ScopeItem>;
    private var _parent :Scope = null;
    private var _newExprs :Map<String, Array<Expr>>;
}