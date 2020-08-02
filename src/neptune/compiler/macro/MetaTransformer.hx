package neptune.compiler.macro;

import haxe.macro.Expr;

class MetaTransformer
{
    public static function transformField(fn :Expr -> Expr, field :Field) : Field
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
                        expr: transformExpr(fn, f.expr),
                        params: f.params
                    }),
                    pos: field.pos,
                    meta: field.meta
                };
                }
            case FVar(t, e):
                {
                    name: field.name,
                    doc: field.doc,
                    access: [APublic],
                    kind: FVar(t, transformExpr(fn, e)),
                    pos: field.pos,
                    meta: field.meta
                };
            case FProp(get, set, t, e):
                {
                    name: field.name,
                    doc: field.doc,
                    access: [APublic],
                    kind: FProp(get, set, t, transformExpr(fn, e)),
                    pos: field.pos,
                    meta: field.meta
                };
        }
    }

    public static function transformExpr(fn :Expr -> Expr, expr :Expr) : Expr
    {
        if(expr == null) return null;
        return switch expr.expr {
            case EArray(e1, e2): 
                expr;
            case EArrayDecl(values): 
                {
                    pos: expr.pos,
                    expr: EArrayDecl(values.map(transformExpr.bind(fn)))
                }
            case EBinop(op, e1, e2): 
                {
                    pos: expr.pos,
                    expr: EBinop(
                        op,
                        transformExpr(fn, e1),
                        transformExpr(fn, e2)
                    )
                }
            case EBlock(exprs):
                {
                    pos: expr.pos,
                    expr: EBlock(exprs.map(transformExpr.bind(fn)))
                }
            case EBreak: 
                expr;
            case ECall(e, params): 
                expr;
            case ECast(e, t): 
                {
                    pos: expr.pos,
                    expr: ECast(transformExpr(fn, e), t)
                }
            case ECheckType(e, t): 
                {
                    pos: expr.pos,
                    expr: ECheckType(transformExpr(fn, e), t)
                }
            case EConst(c):
                expr;
            case EContinue: 
                expr;
            case EDisplay(e, displayKind): 
                {
                    pos: expr.pos,
                    expr: EDisplay(transformExpr(fn, e), displayKind)
                }
            case EDisplayNew(t): 
                expr;
            case EField(e, field): 
                expr;
            case EFor(it, expr): 
                expr;
            case EFunction(kind, f): 
                expr;
            case EIf(econd, eif, eelse): 
                {
                    pos: expr.pos,
                    expr: EIf(
                        transformExpr(fn, econd),
                        transformExpr(fn, eif),
                        transformExpr(fn, eelse)
                    )
                }
            case EMeta(s, e):
                fn(e);
            case ENew(t, params): 
                {
                    pos: expr.pos,
                    expr: ENew(t, params.map(transformExpr.bind(fn)))
                }
            case EObjectDecl(fields): 
                expr;
            case EParenthesis(e): 
                {
                    pos: expr.pos,
                    expr: EParenthesis(transformExpr(fn, e))
                }
            case EReturn(e):
                {
                    pos: expr.pos,
                    expr: EReturn(transformExpr(fn, e))
                }
            case ESwitch(e, cases, edef): 
                {
                    pos: expr.pos,
                    expr: ESwitch(
                        transformExpr(fn, e),
                        cases.map(transformCase.bind(fn)),
                        transformExpr(fn, edef)
                    )
                }
            case ETernary(econd, eif, eelse):
                {
                    pos: expr.pos,
                    expr: ETernary(
                        transformExpr(fn, econd),
                        transformExpr(fn, eif),
                        transformExpr(fn, eelse)
                    )
                }
            case EThrow(e): 
                expr;
            case ETry(e, catches): 
                {
                    pos: expr.pos,
                    expr: ETry(transformExpr(fn, e), catches.map(transformCatch.bind(fn)))
                }
            case EUnop(op, postFix, e): 
                expr;
            case EUntyped(e): 
                {
                    pos: expr.pos,
                    expr: EUntyped(transformExpr(fn, e))
                }
            case EVars(vars):
                {
                    pos: expr.pos,
                    expr: EVars(vars.map(v -> {
                        name: v.name,
                        type: v.type,
                        expr: transformExpr(fn, v.expr),
                        isFinal: v.isFinal
                    }))
                }
            case EWhile(econd, e, normalWhile): 
                expr;
        }
    }
    
    private static function transformCase(fn :Expr -> Expr, case_ :Case) : Case
    {
        return {
            values: case_.values.map(transformExpr.bind(fn)),
            guard: transformExpr(fn, case_.guard),
            expr: transformExpr(fn, case_.expr)
        };
    }
    
    private static function transformCatch(fn :Expr -> Expr, catch_ :Catch) : Catch
    {
        return {
            name: catch_.name,
            type: catch_.type,
            expr: transformExpr(fn, catch_.expr)
        };
    }
}