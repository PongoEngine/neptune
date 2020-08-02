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

enum ScopeType
{
    SFields(fields :Array<Field>);
    SExprs(exprs :Array<Expr>);
}

class Scope
{
    public var parent :Scope = null;
    public var block :ScopeType;

    public function new(block :ScopeType) : Void
    {
        _items = new Map<String, ScopeItem>();
        this.block = block;
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
        else if(parent != null) {
            return parent.exists(name);
        }
        else {
            return false;
        }
    }

    public function get(name :String) : Null<ScopeItem>
    {
        if(_items.exists(name)) {
            return _items.get(name);
        }
        else if(parent != null) {
            return parent.get(name);
        }
        else {
            return null;
        }
    }

    public function createChild(block :ScopeType) : Scope
    {
        var c = new Scope(block);
        c.parent = this;
        return c;
    }

    private var _items :Map<String, ScopeItem>;
}