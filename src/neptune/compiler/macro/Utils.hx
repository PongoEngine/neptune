package neptune.compiler.macro;

import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
class Utils
{
    public static function cleanWhitespace(str :String) : String
    {
        var reg = ~/\s\s+/g;
        return reg.replace(str, " ");
    }

    private static var _fieldIndex = 0;
    public static function createDefFieldName() : String
    {
        return 'var_${_fieldIndex++}';
    }

    public static function createDefVar(e :Expr, name :String) : ExprDef
    {
        return EVars([{name:name, type: null, expr: e}]);
    }

    public static function createDefString(str :String) : ExprDef
    {
        return EConst(CString(str));
    }

    public static function createDefIdent(ident :String) : ExprDef
    {
        return EConst(CIdent(ident));
    }

    public static function createDefCall(args :Array<Expr>, fnName :String) : ExprDef
    {
        return ECall({
            expr: EConst(CIdent(fnName)),
            pos: Context.currentPos()
        }, args);
    }

    public static function createDefBlock(exprs :Array<Expr>) : ExprDef
    {
        return EBlock(exprs);
    }

    public static function createDefArrayDecl(exprs :Array<Expr>) : ExprDef
    {
        return EArrayDecl(exprs);
    }

    public static function createDefBinop(binop :Binop, e1 :Expr, e2 :Expr) : ExprDef
    {
        return EBinop(OpAssign, e1, e2);
    }

    public static function createDefReturn(e :Expr) : ExprDef
    {
        return EReturn(e);
    }

    public static function createDefAnonFunc(e :Expr) : ExprDef
    {
        return EFunction(FunctionKind.FAnonymous, {
            args: [],
            ret: null,
            expr: e
        });
    }

    public static function cloneExpr(e :Expr) : Expr
    {
        return {
            pos: e.pos,
            expr: e.expr
        }
    }

    public static function toExpr(e :ExprDef) : Expr
    {
        return {
            pos: Context.currentPos(),
            expr: e
        }
    }
}
#end