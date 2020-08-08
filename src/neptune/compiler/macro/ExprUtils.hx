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
import haxe.macro.Context;
import haxe.macro.Printer;

class ExprUtils
{
    public static function print(e :Expr) : Void
    {
        var p = new Printer("  ");
        trace('\n${p.printExpr(e)}\n');
    }

    public static function createDefVar(e :Expr, name :String) : ExprDef
    {
        return EVars([{name:name, type: null, expr: e}]);
    }

    public static function createDefVars(vars :Array<{name :String, e :Expr}>) : ExprDef
    {
        return EVars(vars.map(item -> {{name:item.name, type: null, expr: item.e, isFinal: false}}));
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

    public static function createDefField(e :Expr, field :String) : ExprDef
    {
        return EField(e, field);
    }

    public static function createDefFunc(body :Expr, name :String, args :Array<String>) : ExprDef
    {
        return EFunction(FunctionKind.FNamed(name), {
            args: args.map(a -> {
                name: a,
                opt: false,
                type: null,
                value: null,
                meta: null
            }),
            ret: null,
            expr: body
        });
    }

    public static function createDefFuncAnon(body :Expr, args :Array<String>) : ExprDef
    {
        return EFunction(FunctionKind.FAnonymous, {
            args: args.map(a -> {
                name: a,
                opt: false,
                type: null,
                value: null,
                meta: null
            }),
            ret: null,
            expr: body
        });
    }

    public static function cloneExpr(e :Expr) : Expr
    {
        return {
            pos: e.pos,
            expr: e.expr
        }
    }

    public static function updateDef(e :Expr, def :ExprDef) : Expr
    {
        e.expr = def;
        return e;
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