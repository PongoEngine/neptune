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
import haxe.macro.Context;
import haxe.macro.Expr;
import neptune.compiler.dom.Scanner;
import neptune.compiler.dom.Parser;
import neptune.compiler.macro.scope.Scope;
using neptune.compiler.macro.ExprUtils;
using neptune.util.NStringUtils;

class CompileEArray
{
    public static function compile(scope :Scope, original :Expr, e1 :Expr, e2 :Expr) : Expr
    {
        var ident1 = Compile.createIdent("arra");
        var ident2 = Compile.createIdent("lastIndex");
        var lastIndex = e2
            .createDefVar(ident2)
            .toExpr();
        scope.addVar(lastIndex);
        var varExpr = original
            .createDefVar(ident1)
            .toExpr();
        scope.addVar(varExpr);

        var left = EArray(e1, ident2.createDefIdent().toExpr()).toExpr();

        var update1 = [left, original]
            .createDefCall("updateNode")
            .toExpr();
        var update2 = OpAssign.createDefBinop(
            ident2.createDefIdent().toExpr(),
            e2
        ).toExpr();
        var update = [update1, update2].createDefBlock().toExpr();

        scope.addUpdate(update);
        return ident1.createDefIdent().toExpr();
    }
}
#end