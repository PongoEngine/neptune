package neptune.compiler.macro.scope;

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
import neptune.util.Set;
using neptune.compiler.macro.ExprUtils;
using neptune.compiler.macro.scope.DepsUtil;

class ScopeBlock implements Scope
{
    public var parent :Scope;
    public var children :Array<Scope>;

    public function new(block :Array<Expr>) : Void
    {
        this.children = [];
        _block = block;
        _vars = new Map<String, Var>();
        _varExprs = [];
        _updates = [];
        _assignments = new Set<String>();
        _setters = new Map<String, Array<Expr>>();
    }

    public function createChild(block :Array<Expr>) : Scope
    {
        var c = new ScopeBlock(block);
        c.parent = this;
        this.children.push(c);
        return c;
    }

    public function runThrough(fn :Scope -> Void) : Void
    {
        for(c in children) {
            c.runThrough(fn);
        }
        fn(this);
    }

    public inline function saveVar(var_ :Var) : Void
    {
        _vars.set(var_.name, var_);
        if(!_setters.exists(var_.name)) {
            _setters.set(var_.name, []);
        }
    }

    public inline function getVar(name :String) : Var
    {
        return _vars.get(name);
    }

    public function addVarExpr(expr :Expr) : Void
    {
        _varExprs.push(expr);
    }

    /**
     * Raw dom update that needs to be called when dependency is updated.
     * @param expr 
     */
    public function addUpdateExpr(expr :Expr) : Void
    {
        _updates.push(expr);
    }

    public inline function transformAssignment(assignment :Expr) : Void
    {
        var ident = AssignmentUtil.transformAssignment(assignment);
        if(ident != null) {
            _assignments.set(ident);
        }
    }

    public function updateBlock() : Void
    {
        if(this.parent != null) {
            this.parent.pushAssignments(_assignments);
        }

        for(update in _updates) {
            for(dep in Deps.from(update)) {
                if(_setters.exists(dep)) {
                    _setters.get(dep).push(update);
                }
            }
        }

        addVarsToBlock();

        for(setter in _setters.keyValueIterator()) {
            if(_assignments.exists(setter.key)) {
                var tempSetter = AssignmentUtil.createSetterTemp(setter.key);
                _block.unshift(tempSetter);
                var fullSetter = AssignmentUtil.createSetter(setter.key, setter.value);
                _block.insertBeforeReturn(fullSetter);
            }
        }
    }

    public function pushAssignments(?newAssignments :Set<String>) : Void
    {
        if(newAssignments != null) {
            for(assignment in newAssignments) {
                _assignments.set(assignment);
            }
        }
        
        if(this.parent != null) {
            this.parent.pushAssignments(_assignments);
        }
    }

    private function addVarsToBlock() {
        for(expr in _varExprs) {
            switch expr.expr {
                case EVars(vars):
                    if(vars.length != 1) throw "err";
                    if(_block.length == 1) {
                        Context.warning("Not sure if safe", Context.currentPos());
                        _block.unshift(expr);
                    }
                    else {
                        var deps = new Deps().findDeps(vars[0].expr);
                        var index = deps.getInsertIndex(_block);
                        _block.insert(index, expr);
                    }
                case _:
                    throw "impossible";
            }
        }
    }

    private var _block :Array<Expr>;
    private var _vars :Map<String, Var>;
    private var _updates :Array<Expr>;
    private var _varExprs :Array<Expr>;
    private var _setters :Map<String, Array<Expr>>;
    private var _assignments :Set<String>;
}

#end