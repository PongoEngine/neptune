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
    public static function compile(scope :Scope, it :Expr, expr :Expr) : Expr
    {
        var fragIdent = Compile.createIdent("for_frag");
        var forExpr = createForExpr(fragIdent, scope, expr);

        return wrapLoop(fragIdent, it, forExpr);
    }

    private static function createForExpr(fragIdent :String, scope :Scope, expr :Expr) : Expr
    {
        var block = [];
        var child = scope.createChild(block);
        var compiledExpr = Compile.handleDomExpr(child, expr);
        block.push(appendChild(fragIdent,  compiledExpr));
        return block.createDefBlock().toExpr();
    }

    private static function appendChild(fragIdent :String, expr :Expr) : Expr
    {
        var appendChild = EField(fragIdent.createDefIdent().toExpr(), "appendChild").toExpr();
        return ECall(appendChild, [expr]).toExpr();
    }

    private static function wrapLoop(fragIdent :String, it :Expr, expr :Expr) : Expr
    {
        var frag = [].createDefCall("createFragment").toExpr().createDefVar(fragIdent).toExpr();
        var fragIdentExpr = fragIdent.createDefIdent().toExpr();

        return [frag, EFor(it, expr).toExpr(), fragIdentExpr].createDefBlock().toExpr();
    }
}
#end