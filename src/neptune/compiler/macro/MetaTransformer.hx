package neptune.compiler.macro;

import haxe.macro.Expr;

class MetaTransformer
{
    public static function transformField(fn :Scope -> Expr -> Expr, scope :Scope, field :Field) : Field
    {
        return switch field.kind {
            case FFun(f): {
                {
                    name: field.name,
                    doc: field.doc,
                    access: [APublic],
                    kind: FFun({
                        args: f.args,
                        ret: f.ret,
                        expr: transformExpr(fn, scope.createChild(), f.expr),
                        params: f.params
                    }),
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
                    kind: FVar(t, transformExpr(fn, scope, e)),
                    pos: field.pos,
                    meta: field.meta
                };
            case FProp(get, set, t, e):
                scope.addItem(field.name, SField(field));
                {
                    name: field.name,
                    doc: field.doc,
                    access: [APublic],
                    kind: FProp(get, set, t, transformExpr(fn, scope, e)),
                    pos: field.pos,
                    meta: field.meta
                };
        }
    }

    public static function transformExpr(fn :Scope -> Expr -> Expr, scope :Scope, expr :Expr) : Expr
    {
        if(expr == null) return null;
        return switch expr.expr {
            case EArray(e1, e2): 
                expr;
            case EArrayDecl(values): 
                {
                    pos: expr.pos,
                    expr: EArrayDecl(values.map(transformExpr.bind(fn, scope)))
                }
            case EBinop(op, e1, e2): 
                {
                    pos: expr.pos,
                    expr: EBinop(
                        op,
                        transformExpr(fn, scope, e1),
                        transformExpr(fn, scope, e2)
                    )
                }
            case EBlock(exprs):
                {
                    pos: expr.pos,
                    expr: EBlock(exprs.map(transformExpr.bind(fn, scope.createChild())))
                }
            case EBreak: 
                expr;
            case ECall(e, params): 
                expr;
            case ECast(e, t): 
                {
                    pos: expr.pos,
                    expr: ECast(transformExpr(fn, scope, e), t)
                }
            case ECheckType(e, t): 
                {
                    pos: expr.pos,
                    expr: ECheckType(transformExpr(fn, scope, e), t)
                }
            case EConst(c):
                expr;
            case EContinue: 
                expr;
            case EDisplay(e, displayKind): 
                {
                    pos: expr.pos,
                    expr: EDisplay(transformExpr(fn, scope, e), displayKind)
                }
            case EDisplayNew(t): 
                expr;
            case EField(e, field): 
                expr;
            case EFor(it, e): 
                {
                    pos: expr.pos,
                    expr: EFor(it, transformExpr(fn, scope, e))
                }
            case EFunction(kind, f): 
                {
                    pos: expr.pos,
                    expr: EFunction(kind, transformFunction(fn, scope, f))
                }
            case EIf(econd, eif, eelse): 
                {
                    pos: expr.pos,
                    expr: EIf(
                        transformExpr(fn, scope, econd),
                        transformExpr(fn, scope, eif),
                        transformExpr(fn, scope, eelse)
                    )
                }
            case EMeta(s, e):
                fn(scope, e);
            case ENew(t, params): 
                {
                    pos: expr.pos,
                    expr: ENew(t, params.map(transformExpr.bind(fn, scope)))
                }
            case EObjectDecl(fields): 
                expr;
            case EParenthesis(e): 
                {
                    pos: expr.pos,
                    expr: EParenthesis(transformExpr(fn, scope, e))
                }
            case EReturn(e):
                {
                    pos: expr.pos,
                    expr: EReturn(transformExpr(fn, scope, e))
                }
            case ESwitch(e, cases, edef): 
                {
                    pos: expr.pos,
                    expr: ESwitch(
                        transformExpr(fn, scope, e),
                        cases.map(transformCase.bind(fn, scope)),
                        transformExpr(fn, scope, edef)
                    )
                }
            case ETernary(econd, eif, eelse):
                {
                    pos: expr.pos,
                    expr: ETernary(
                        transformExpr(fn, scope, econd),
                        transformExpr(fn, scope, eif),
                        transformExpr(fn, scope, eelse)
                    )
                }
            case EThrow(e): 
                {
                    pos: expr.pos,
                    expr: EThrow(transformExpr(fn, scope, e))
                }
            case ETry(e, catches): 
                {
                    pos: expr.pos,
                    expr: ETry(transformExpr(fn, scope, e), catches.map(transformCatch.bind(fn, scope)))
                }
            case EUnop(op, postFix, e): 
                expr;
            case EUntyped(e): 
                {
                    pos: expr.pos,
                    expr: EUntyped(transformExpr(fn, scope, e))
                }
            case EVars(vars):
                {
                    pos: expr.pos,
                    expr: EVars(vars.map(v -> {
                        scope.addItem(v.name, SExpr(v.expr));
                        return {
                            name: v.name,
                            type: v.type,
                            expr: transformExpr(fn, scope, v.expr),
                            isFinal: v.isFinal
                        }
                    }))
                }
            case EWhile(econd, e, normalWhile): 
                {
                    pos: expr.pos,
                    expr: EWhile(econd, transformExpr(fn, scope, e), normalWhile)
                }
        }
    }
    
    private static function transformCase(fn :Scope -> Expr -> Expr, scope :Scope, case_ :Case) : Case
    {
        return {
            values: case_.values.map(transformExpr.bind(fn, scope)),
            guard: transformExpr(fn, scope, case_.guard),
            expr: transformExpr(fn, scope, case_.expr)
        };
    }
    
    private static function transformCatch(fn :Scope -> Expr -> Expr, scope :Scope, catch_ :Catch) : Catch
    {
        return {
            name: catch_.name,
            type: catch_.type,
            expr: transformExpr(fn, scope, catch_.expr)
        };
    }

    private static function transformFunction(fn :Scope -> Expr -> Expr, scope :Scope, function_ :Function) : Function
    {
        return {
            args: function_.args,
            ret: function_.ret,
            expr: transformExpr(fn, scope, function_.expr),
            params: function_.params
        };
    }
}