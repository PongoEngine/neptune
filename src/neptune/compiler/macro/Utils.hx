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
    public static function createFieldName() : String
    {
        return 'var_${_fieldIndex++}';
    }

    public static function createVar(e :Expr, name :String) : Expr 
    {
        return {
            expr: EVars([{name:name, type: null, expr: e}]),
            pos: Context.currentPos()
        }
    }

    public static function createExprString(str :String) : Expr
    {
        return {
            expr: EConst(CString(str)),
            pos: Context.currentPos()
        }
    }

    public static function createExprIdent(ident :String) : Expr
    {
        return {
            expr: EConst(CIdent(ident)),
            pos: Context.currentPos()
        }
    }

    public static function createCall(args :Array<Expr>, fnName :String) : Expr
    {
        return {
            expr: ECall({
                expr: EConst(CIdent(fnName)),
                pos: Context.currentPos()
            }, args),
            pos: Context.currentPos()
        }
    }

    public static function createBlock(exprs :Array<Expr>) : Expr
    {
        return {
            expr: EBlock(exprs),
            pos: Context.currentPos()
        }
    }

    public static function createBinop(binop :Binop, e1 :Expr, e2 :Expr) : Expr
    {
        return {pos: Context.currentPos(), expr: EBinop(OpAssign, e1, e2)};
    }

    public static function createReturn(e :Expr) : Expr
    {
        return {pos: Context.currentPos(), expr: EReturn(e)};
    }

    public static function createAnonFunc(e :Expr) : Expr
    {
        return {
            pos: Context.currentPos(),
            expr: EFunction(FunctionKind.FAnonymous, {
                args: [],
                ret: null,
                expr: e
            })
        }
    }
}
#end