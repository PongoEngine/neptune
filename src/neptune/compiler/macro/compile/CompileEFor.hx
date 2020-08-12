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

class CompileEFor
{
    public static function compile(scope :Scope, original :Expr, it :Expr, expr :Expr) : Expr
    {
        var frag = ["div".createDefString().toExpr()].createDefCall("createElement").toExpr()
            .createDefVar("frag")
            .toExpr();

        var appendChild = EField("frag".createDefIdent().toExpr(), "appendChild").toExpr();
        var callAppendChild = ECall(appendChild, [expr]).toExpr();

        var forExpr = EFor(it, callAppendChild).toExpr();
        var returnExpr = "frag".createDefIdent().toExpr();
        var e = [frag, forExpr, returnExpr].createDefBlock().toExpr();

        var ident = Compile.createIdent("for");
        var forVar = e.createDefVar(ident).toExpr();

        scope.addVar(forVar);
        
        var updateIdent = Compile.createIdent("for_update");
        var update1 = [ident.createDefIdent().toExpr(), e]
            .createDefCall("updateNode").toExpr()
            .createDefVar(updateIdent)
            .toExpr();

        var update2 = OpAssign.createDefBinop(
            ident.createDefIdent().toExpr(),
            ECast(updateIdent.createDefIdent().toExpr(), null).toExpr()
        ).toExpr();

        var update = [update1, update2].createDefBlock().toExpr();

        scope.addUpdate(update);
        
        return ident.createDefIdent().toExpr();
    }
}
#end