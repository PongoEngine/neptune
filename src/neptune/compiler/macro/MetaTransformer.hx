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
    public static function transformField(fn :(scope :Scope, expr :Expr) -> Expr, scope :Scope, assignments :Assignments, field :Field) : Field
    {
        return switch field.kind {
            case FFun(f):
                field.kind = FFun(transformFunction(fn, scope, assignments, f));
                field;
            case FVar(t, e):
                scope.addScopedItem(field.name, false);
                field.kind = FVar(t, transformExpr(fn, scope, assignments, e));
                field;
            case FProp(get, set, t, e):
                scope.addScopedItem(field.name, false);
                field.kind = FProp(get, set, t, transformExpr(fn, scope, assignments, e));
                field;
        }
    }

    public static function transformExpr(fn :(scope :Scope, expr :Expr) -> Expr, scope :Scope, assignments :Assignments, expr :Expr) : Expr
    {
        if(expr == null) return null;
        switch expr.expr {
            case EArray(e1, e2): 
            case EArrayDecl(values): 
                expr.expr = EArrayDecl(values.map(transformExpr.bind(fn, scope, assignments)));
            case EBinop(op, e1, e2): 
                expr.expr = EBinop(
                    op,
                    transformExpr(fn, scope, assignments, e1),
                    transformExpr(fn, scope, assignments, e2)
                );
            case EBlock(exprs):
                var child = scope.createChild(exprs);
                exprs.map(transformExpr.bind(fn, child, assignments));
                child.insertScopedExprs();
                expr.expr = EBlock(exprs);
            case EBreak: 
            case ECall(e, params): 
            case ECast(e, t): 
                expr.expr = ECast(transformExpr(fn, scope, assignments, e), t);
            case ECheckType(e, t): 
                expr.expr = ECheckType(transformExpr(fn, scope, assignments, e), t);
            case EConst(c):
            case EContinue: 
            case EDisplay(e, displayKind): 
                expr.expr = EDisplay(transformExpr(fn, scope, assignments, e), displayKind);
            case EDisplayNew(t): 
            case EField(e, field): 
            case EFor(it, e): 
                expr.expr = EFor(it, transformExpr(fn, scope, assignments, e));
            case EFunction(kind, f): 
                expr.expr = EFunction(kind, transformFunction(fn, scope, assignments, f));
            case EIf(econd, eif, eelse): 
                expr.expr = EIf(
                    transformExpr(fn, scope, assignments, econd),
                    transformExpr(fn, scope, assignments, eif),
                    transformExpr(fn, scope, assignments, eelse)
                );
            case EMeta(s, e):
                expr.expr = fn(scope, e).expr;
            case ENew(t, params): 
                expr.expr = ENew(t, params.map(transformExpr.bind(fn, scope, assignments)));
            case EObjectDecl(fields): 
            case EParenthesis(e): 
                expr.expr = EParenthesis(transformExpr(fn, scope, assignments, e));
            case EReturn(e):
                expr.expr = EReturn(transformExpr(fn, scope, assignments, e));
            case ESwitch(e, cases, edef): 
                expr.expr = ESwitch(
                    transformExpr(fn, scope, assignments, e),
                    cases.map(transformCase.bind(fn, scope, assignments)),
                    transformExpr(fn, scope, assignments, edef)
                );
            case ETernary(econd, eif, eelse):
                expr.expr = ETernary(
                    transformExpr(fn, scope, assignments, econd),
                    transformExpr(fn, scope, assignments, eif),
                    transformExpr(fn, scope, assignments, eelse)
                );
            case EThrow(e): 
                expr.expr = EThrow(transformExpr(fn, scope, assignments, e));
            case ETry(e, catches): 
                expr.expr = ETry(transformExpr(fn, scope, assignments, e), catches.map(transformCatch.bind(fn, scope, assignments)));
            case EUnop(op, postFix, e): 
            case EUntyped(e): 
                expr.expr = EUntyped(transformExpr(fn, scope, assignments, e));
            case EVars(vars):
                for(v in vars) {
                    var isMeta = v.expr.expr.getName() == "EMeta";
                    scope.addScopedItem(v.name, isMeta);
                    v.expr.expr = transformExpr(fn, scope, assignments, v.expr).expr;
                }
            case EWhile(econd, e, normalWhile): 
                expr.expr = EWhile(econd, transformExpr(fn, scope, assignments, e), normalWhile);
        }
        assignments.save(expr);
        return expr;
    }
    
    private static function transformCase(fn :(scope :Scope, expr :Expr) -> Expr, scope :Scope, assignments :Assignments, case_ :Case) : Case
    {
        case_.values = case_.values.map(transformExpr.bind(fn, scope, assignments));
        case_.guard = transformExpr(fn, scope, assignments, case_.guard);
        case_.expr = transformExpr(fn, scope, assignments, case_.expr);
        return case_;
    }
    
    private static function transformCatch(fn :(scope :Scope, expr :Expr) -> Expr, scope :Scope, assignments :Assignments, catch_ :Catch) : Catch
    {
        catch_.expr = transformExpr(fn, scope, assignments, catch_.expr);
        return catch_;
    }

    private static function transformFunction(fn :(scope :Scope, expr :Expr) -> Expr, scope :Scope, assignments :Assignments, function_ :Function) : Function
    {
        function_.args = function_.args.map(transformFunctionArgs.bind(fn, scope, assignments));
        function_.expr = transformExpr(fn, scope, assignments, function_.expr);
        return function_;
    }

    private static function transformFunctionArgs(fn :(scope :Scope, expr :Expr) -> Expr, scope :Scope, assignments :Assignments, arg :FunctionArg) : FunctionArg
    {
        scope.addScopedItem(arg.name, false);
        arg.value = transformExpr(fn, scope, assignments, arg.value);
        return arg;
    }
}
#end