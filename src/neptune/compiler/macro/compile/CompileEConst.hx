package neptune.compiler.macro.compile;

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
import neptune.compiler.macro.scope.Scope;
using neptune.compiler.macro.ExprUtils;
using neptune.util.NStringUtils;

class CompileEConst
{
    public static function compile(scope :Scope, original :Expr, const :Constant) : Expr
    {
        return switch const {
            case CIdent(s):
                if(isElement(scope, s)) {
                    original;
                }
                else {
                    var ident = Compile.createIdent("text");
                    var var_ = [original].createDefCall("createText").toExpr()
                        .createDefVar(ident)
                        .toExpr();
                    var update = [ident.createDefIdent().toExpr(), original]
                        .createDefCall("updateTextNode")
                        .toExpr();

                    scope.addVarExpr(var_);
                    scope.addUpdateExpr(update);

                    ident.createDefIdent().toExpr();
                }
            case _:
                [original].createDefCall("createText").toExpr();
        }
    }

    //not a final solution
    private static function isElement(scope :Scope, ident :String) : Bool
    {
        return switch Context.typeof(scope.getVar(ident).expr) {
            case TInst(t, params):
                t.toString() == "js.html.Element";
            case _:
                false;
        };
    }
}
#end