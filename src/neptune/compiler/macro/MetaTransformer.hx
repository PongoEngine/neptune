package neptune.compiler.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import neptune.compiler.dom.Parser;
using neptune.compiler.macro.Utils;
using haxe.macro.ExprTools;
using StringTools;

class MetaTransformer
{
    public static function transformMarkup(fn :Expr -> Expr, expr :Expr) : Expr
    {
        if(expr == null) return null;
        return switch expr.expr {
            case EArray(e1, e2): 
                expr;
            case EArrayDecl(values): 
                {
                    pos: expr.pos,
                    expr: EArrayDecl(values.map(transformMarkup.bind(fn)))
                }
            case EBinop(op, e1, e2): 
                {
                    pos: expr.pos,
                    expr: EBinop(
                        op,
                        transformMarkup(fn, e1),
                        transformMarkup(fn, e2)
                    )
                }
            case EBlock(exprs):
                {
                    pos: expr.pos,
                    expr: EBlock(exprs.map(transformMarkup.bind(fn)))
                }
            case EBreak: 
                expr;
            case ECall(e, params): 
                expr;
            case ECast(e, t): 
                {
                    pos: expr.pos,
                    expr: ECast(transformMarkup(fn, e), t)
                }
            case ECheckType(e, t): 
                {
                    pos: expr.pos,
                    expr: ECheckType(transformMarkup(fn, e), t)
                }
            case EConst(c):
                expr;
            case EContinue: 
                expr;
            case EDisplay(e, displayKind): 
                {
                    pos: expr.pos,
                    expr: EDisplay(transformMarkup(fn, e), displayKind)
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
                        transformMarkup(fn, econd),
                        transformMarkup(fn, eif),
                        transformMarkup(fn, eelse)
                    )
                }
            case EMeta(s, e):
                fn(e);
            case ENew(t, params): 
                {
                    pos: expr.pos,
                    expr: ENew(t, params.map(transformMarkup.bind(fn)))
                }
            case EObjectDecl(fields): 
                expr;
            case EParenthesis(e): 
                {
                    pos: expr.pos,
                    expr: EParenthesis(transformMarkup(fn, e))
                }
            case EReturn(e):
                {
                    pos: expr.pos,
                    expr: EReturn(transformMarkup(fn, e))
                }
            case ESwitch(e, cases, edef): 
                {
                    pos: expr.pos,
                    expr: ESwitch(
                        transformMarkup(fn, e),
                        cases.map(transformCase.bind(fn)),
                        transformMarkup(fn, edef)
                    )
                }
            case ETernary(econd, eif, eelse):
                {
                    pos: expr.pos,
                    expr: ETernary(
                        transformMarkup(fn, econd),
                        transformMarkup(fn, eif),
                        transformMarkup(fn, eelse)
                    )
                }
            case EThrow(e): 
                expr;
            case ETry(e, catches): 
                {
                    pos: expr.pos,
                    expr: ETry(transformMarkup(fn, e), catches.map(transformCatch.bind(fn)))
                }
            case EUnop(op, postFix, e): 
                expr;
            case EUntyped(e): 
                {
                    pos: expr.pos,
                    expr: EUntyped(transformMarkup(fn, e))
                }
            case EVars(vars):
                {
                    pos: expr.pos,
                    expr: EVars(vars.map(v -> {
                        name: v.name,
                        type: v.type,
                        expr: transformMarkup(fn, v.expr),
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
            values: case_.values.map(transformMarkup.bind(fn)),
            guard: transformMarkup(fn, case_.guard),
            expr: transformMarkup(fn, case_.expr)
        };
    }
    
    private static function transformCatch(fn :Expr -> Expr, catch_ :Catch) : Catch
    {
        return {
            name: catch_.name,
            type: catch_.type,
            expr: transformMarkup(fn, catch_.expr)
        };
    }
}