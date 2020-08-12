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

#if macro
import haxe.macro.Expr;
import neptune.compiler.macro.scope.Scope;
using neptune.compiler.macro.ExprUtils;
using neptune.util.NStringUtils;

class CompileEIf
{
    public static function compile(scope :Scope, original :Expr, econd :Expr, eif :Expr, eelse :Null<Expr>) : Expr
    {
        var leftIdent = Compile.createIdent("left");
        var left = Compile.handleDomExpr(scope, eif)
            .createDefVar(leftIdent)
            .toExpr();
        scope.addVarExpr(left);

        var rightIdent = Compile.createIdent("right");
        handleElse(scope, eelse, rightIdent);

        var ifElseIdent = Compile.createIdent("ifelse");
        var ifExpr = EIf(econd, leftIdent.createDefIdent().toExpr(), rightIdent.createDefIdent().toExpr()).toExpr()
            .createDefVar(ifElseIdent)
            .toExpr();
        scope.addVarExpr(ifExpr);

        var update = [econd, leftIdent.createDefIdent().toExpr(), rightIdent.createDefIdent().toExpr()]
            .createDefCall("updateParent")
            .toExpr();
            
        scope.addUpdateExpr(update);
        return ifElseIdent.createDefIdent().toExpr();
    }

    private static function handleElse(scope :Scope, eelse :Null<Expr>, rightIdent :String) 
    {
        if(eelse != null) {
            var right = Compile.handleDomExpr(scope, eelse)
                .createDefVar(rightIdent)
                .toExpr();
            scope.addVarExpr(right);
        }
        else {
            var right = [].createDefCall("createBlank").toExpr()
                .createDefVar(rightIdent)
                .toExpr();
            scope.addVarExpr(right);
        }
    }
}
#end