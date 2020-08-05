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

class MetaTransformer
{
    public static function transformField(fn :Scope -> Expr -> Expr, scope :Scope, setter :Setter, field :Field) : Field
    {
        return switch field.kind {
            case FFun(f): {
                {
                    name: field.name,
                    doc: field.doc,
                    access: [APublic],
                    kind: FFun(transformFunction(fn, scope, setter, f)),
                    pos: field.pos,
                    meta: field.meta
                };
                }
            case FVar(t, e):
                scope.addItem(field.name, SField(field));
                {
                    name: field.name,
                    doc: field.doc,
                    access: [APublic],
                    kind: FVar(t, transformExpr(fn, scope, setter, e)),
                    pos: field.pos,
                    meta: field.meta
                };
            case FProp(get, set, t, e):
                scope.addItem(field.name, SField(field));
                {
                    name: field.name,
                    doc: field.doc,
                    access: [APublic],
                    kind: FProp(get, set, t, transformExpr(fn, scope, setter, e)),
                    pos: field.pos,
                    meta: field.meta
                };
        }
    }

    public static function transformExpr(fn :Scope -> Expr -> Expr, scope :Scope, setter :Setter, expr :Expr) : Expr
    {
        if(expr == null) return null;
        var updatedExpr = switch expr.expr {
            case EArray(e1, e2): 
                expr;
            case EArrayDecl(values): 
                {
                    pos: expr.pos,
                    expr: EArrayDecl(values.map(transformExpr.bind(fn, scope, setter)))
                }
            case EBinop(op, e1, e2): 
                {
                    pos: expr.pos,
                    expr: EBinop(
                        op,
                        transformExpr(fn, scope, setter, e1),
                        transformExpr(fn, scope, setter, e2)
                    )
                }
            case EBlock(exprs):
                {
                    pos: expr.pos,
                    expr: EBlock({
                        var child = scope.createChild();
                        var blockExprs = exprs.map(transformExpr.bind(fn, child, setter));
                        child.insertScopedExprs(blockExprs);
                        blockExprs;
                    })
                }
            case EBreak: 
                expr;
            case ECall(e, params): 
                expr;
            case ECast(e, t): 
                {
                    pos: expr.pos,
                    expr: ECast(transformExpr(fn, scope, setter, e), t)
                }
            case ECheckType(e, t): 
                {
                    pos: expr.pos,
                    expr: ECheckType(transformExpr(fn, scope, setter, e), t)
                }
            case EConst(c):
                expr;
            case EContinue: 
                expr;
            case EDisplay(e, displayKind): 
                {
                    pos: expr.pos,
                    expr: EDisplay(transformExpr(fn, scope, setter, e), displayKind)
                }
            case EDisplayNew(t): 
                expr;
            case EField(e, field): 
                expr;
            case EFor(it, e): 
                {
                    pos: expr.pos,
                    expr: EFor(it, transformExpr(fn, scope, setter, e))
                }
            case EFunction(kind, f): 
                {
                    pos: expr.pos,
                    expr: EFunction(kind, transformFunction(fn, scope, setter, f))
                }
            case EIf(econd, eif, eelse): 
                {
                    pos: expr.pos,
                    expr: EIf(
                        transformExpr(fn, scope, setter, econd),
                        transformExpr(fn, scope, setter, eif),
                        transformExpr(fn, scope, setter, eelse)
                    )
                }
            case EMeta(s, e):
                fn(scope, e);
            case ENew(t, params): 
                {
                    pos: expr.pos,
                    expr: ENew(t, params.map(transformExpr.bind(fn, scope, setter)))
                }
            case EObjectDecl(fields): 
                expr;
            case EParenthesis(e): 
                {
                    pos: expr.pos,
                    expr: EParenthesis(transformExpr(fn, scope, setter, e))
                }
            case EReturn(e):
                {
                    pos: expr.pos,
                    expr: EReturn(transformExpr(fn, scope, setter, e))
                }
            case ESwitch(e, cases, edef): 
                {
                    pos: expr.pos,
                    expr: ESwitch(
                        transformExpr(fn, scope, setter, e),
                        cases.map(transformCase.bind(fn, scope, setter)),
                        transformExpr(fn, scope, setter, edef)
                    )
                }
            case ETernary(econd, eif, eelse):
                {
                    pos: expr.pos,
                    expr: ETernary(
                        transformExpr(fn, scope, setter, econd),
                        transformExpr(fn, scope, setter, eif),
                        transformExpr(fn, scope, setter, eelse)
                    )
                }
            case EThrow(e): 
                {
                    pos: expr.pos,
                    expr: EThrow(transformExpr(fn, scope, setter, e))
                }
            case ETry(e, catches): 
                {
                    pos: expr.pos,
                    expr: ETry(transformExpr(fn, scope, setter, e), catches.map(transformCatch.bind(fn, scope, setter)))
                }
            case EUnop(op, postFix, e): 
                expr;
            case EUntyped(e): 
                {
                    pos: expr.pos,
                    expr: EUntyped(transformExpr(fn, scope, setter, e))
                }
            case EVars(vars):
                {
                    pos: expr.pos,
                    expr: EVars(vars.map(v -> {
                        scope.addItem(v.name, SExpr(v.expr));
                        return {
                            name: v.name,
                            type: v.type,
                            expr: transformExpr(fn, scope, setter, v.expr),
                            isFinal: v.isFinal
                        }
                    }))
                }
            case EWhile(econd, e, normalWhile): 
                {
                    pos: expr.pos,
                    expr: EWhile(econd, transformExpr(fn, scope, setter, e), normalWhile)
                }
        }
        setter.save(updatedExpr);
        return updatedExpr;
    }
    
    private static function transformCase(fn :Scope -> Expr -> Expr, scope :Scope, setter :Setter, case_ :Case) : Case
    {
        return {
            values: case_.values.map(transformExpr.bind(fn, scope, setter)),
            guard: transformExpr(fn, scope, setter, case_.guard),
            expr: transformExpr(fn, scope, setter, case_.expr)
        };
    }
    
    private static function transformCatch(fn :Scope -> Expr -> Expr, scope :Scope, setter :Setter, catch_ :Catch) : Catch
    {
        return {
            name: catch_.name,
            type: catch_.type,
            expr: transformExpr(fn, scope, setter, catch_.expr)
        };
    }

    private static function transformFunction(fn :Scope -> Expr -> Expr, scope :Scope, setter :Setter, function_ :Function) : Function
    {
        var childScope = scope.createChild();
        var func = {
            args: function_.args.map(transformFunctionArgs.bind(fn, childScope, setter)),
            ret: function_.ret,
            expr: transformExpr(fn, childScope, setter, function_.expr),
            params: function_.params
        };

        switch func.expr.expr {
            case EBlock(exprs): childScope.insertScopedExprs(exprs);
            case _: throw "not imlemented";
        }

        return func;
    }

    private static function transformFunctionArgs(fn :Scope -> Expr -> Expr, scope :Scope, setter :Setter, arg :FunctionArg) : FunctionArg
    {
        scope.addItem(arg.name, SExpr(arg.value));
        return {
            name: arg.name,
            opt: arg.opt,
            type: arg.type,
            value: transformExpr(fn, scope, setter, arg.value),
            meta: arg.meta
        };
    }
}
#end