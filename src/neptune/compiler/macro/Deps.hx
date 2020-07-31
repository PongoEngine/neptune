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
import haxe.macro.Context;
using neptune.compiler.macro.Utils;

#if macro
class Deps
{
    public function new() : Void
    {
        _deps = new Map<String, Dep>();
        _topLevel = [];
    }

    public function pushTopLevel(fieldName :String, expr :Expr) : Void
    {
        _topLevel.push({fieldname:fieldName, expr: expr});
    }

    public function pushSetter(depIdent :String, expr :Expr) : Void
    {
        this.getDep(depIdent).setterFns.push(expr);
    }

    public function transformDependentFields(fields :Array<Field>) : Array<Field>
    {
        return fields.map(field -> {
            if(_deps.exists(field.name)) {
                return switch field.kind {
                    case FVar(t, e):
                        {
                            name:field.name,
                            doc:field.doc,
                            access: field.access,
                            kind: FProp("default", "set", t, e),
                            pos: field.pos,
                            meta: field.meta,
                        }
                    case _:
                        throw "not implemented"; 
                }
            }
            else {
                return field;
            }
        });
    }

    public function createDependentSetters(fields :Array<Field>) : Array<Field>
    {
        var dependentSetters = [];
        for(field in fields) {
            if(_deps.exists(field.name)) {
                switch field.kind {
                    case FVar(t, e):
                        dependentSetters.push(createSetter(field.name, e.pos));
                    case _:
                        throw "not implemented";
                }
            }
        }
        return dependentSetters;
    }

    public function createConstructorFields() :Array<Field>
    {
        var fields = [];
        for(tl in _topLevel) {
            fields.push({
                pos: Context.currentPos(),
                name: tl.fieldname,
                access: [Access.APublic],
                kind: FVar(macro:Dynamic, null)
            });
        }
        return fields;
    }

    public function createConstructor() : Field
    {
        var nExprs = [];
        for(tl in _topLevel) {
            nExprs.push(Binop.OpAssign.createBinop(tl.fieldname.createExprIdent(), tl.expr));
        }

        return {
            name: "new",
            kind: FFun({
                args: [],
                ret: null,
                expr: nExprs.createBlock(),
                params: null
            }),
            access: [APublic],
            pos: Context.currentPos()
        }
    }

    private function getDep(name :String) : Dep
    {
        if(!_deps.exists(name)) {
            _deps.set(name, new Dep());
        }
        return _deps.get(name);
    }

    private function createSetter(fieldName :String, position :Position) : Field
    {
        return {
            pos: Context.currentPos(),
            name: 'set_${fieldName}',
            access: [APublic],
            kind: FFun({
                args: [{name:"val", type: null}],
                ret: null,
                expr: {
                    pos: position,
                    expr: EBlock([
                        OpAssign.createBinop(fieldName.createExprIdent(), "val".createExprIdent()),
                        createDependentUpdate(fieldName),
                        Utils.createReturn("val".createExprIdent())
                    ])
                }
            })
        };
    }

    private function createDependentUpdate(fieldName :String) : Expr
    {
        var exprs = _deps.get(fieldName).setterFns;
        var arraCbs :Expr = {pos:Context.currentPos(), expr: EArrayDecl(exprs)};
        return [arraCbs].createCall("updateDependencies");
    }

    private var _deps :Map<String, Dep>;
    private var _topLevel :Array<{fieldname :String, expr :Expr}>;
}
#end

class Dep
{
    public var setterFns :Array<Expr>;

    public function new() : Void
    {
        this.setterFns = [];
    }
}