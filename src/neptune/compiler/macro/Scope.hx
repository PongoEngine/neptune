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
        _items = new Map<String, ScopeItem>();
        _newExprs = [];
        _assignments = [];
        _children = [];
    }

    public function addItem(name :String, item :ScopeItem) : Void
    {
        _items.set(name, item);
    }

    public function saveAssignment(expr :Expr) : Void
    {
        _assignments.push(expr);
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

    public function setBlock(block :Array<Expr>) : Void
    {
        if(_block != null) {
            throw "block is already set";
        }
        _block = block;
    }

    public function insertScopedExprs() : Void
    {
        if(_hasInsertedExprs) {
            throw "Already inserted Expressions";
        }

        if(_block != null) {
            for(dep in _newExprs.keyValueIterator()) {
                var ident = dep.key;
                var exprs = dep.value;
                var index = getIndex(ident);
                for(expr in exprs) {
                    _block.insert(index++, expr);
                }
                _block.insert(index++, createSetter(ident));
            }
        }

        for(child in _children) {
            child.insertScopedExprs();
        }
    }

    private function createSetter(ident :String) : Expr
    {
        var argName = 'new_${ident}';
        var assignmentExpr = OpAssign.createDefBinop(ident.createDefIdent().toExpr(), argName.createDefIdent().toExpr())
            .toExpr();

        var nodeName = 'nep_${ident}';
        var updateFunc = [nodeName.createDefIdent().toExpr(), ident.createDefIdent().toExpr()]
            .createDefCall("updateTextNode")
            .toExpr();

        var blockExpr = [assignmentExpr, updateFunc]
            .createDefBlock()
            .toExpr();


        return blockExpr.createDefFunc('set_${ident}', [argName])
            .toExpr();

    }

    public function createChild() : Scope
    {
        var c = new Scope();
        c._parent = this;
        _children.push(c);
        return c;
    }

    //wasteful
    private function getIndex(ident :String) : Int
    {
        var index = 1;
        for(item in _block) {
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
    private var _children :Array<Scope>;
    private var _newExprs :Map<String, Array<Expr>>;
    private var _assignments :Array<Expr>;
    private var _block :Array<Expr>;
    private var _hasInsertedExprs = false;
}
#end