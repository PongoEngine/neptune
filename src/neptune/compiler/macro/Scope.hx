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
            _newExprs.push(expr);
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
        for(nExpr in _newExprs) {
            block.unshift(nExpr);
        }
    }

    public function createChild() : Scope
    {
        var c = new Scope();
        c._parent = this;
        return c;
    }

    private var _items :Map<String, ScopeItem>;
    private var _parent :Scope = null;
    private var _newExprs :Array<Expr>;
}