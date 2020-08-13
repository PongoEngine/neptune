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
        var fragIdent = Compile.createIdent("frag");
        var frag = createFragment(fragIdent);
        var callAppendChild = appendChild(fragIdent, scope, expr);
        var forExpr = forBlock(fragIdent, it, frag, callAppendChild);

        var forIdent = Compile.createIdent("for");

        var updateFunc = forExpr
            .createDefFuncAnon([])
            .toExpr()
            .createDefVar(forIdent)
            .toExpr();

        scope.addVarExpr(updateFunc);
        
        return [].createDefCall(forIdent).toExpr();
    }

    private static function createFragment(ident :String) : Expr
    {
        return [].createDefCall("createFragment").toExpr()
            .createDefVar(ident)
            .toExpr();
    }

    private static function appendChild(fragIdent :String, scope :Scope, expr :Expr) : Expr
    {
        var appendChild = EField(fragIdent.createDefIdent().toExpr(), "appendChild").toExpr();
        var compiledExpr = Compile.handleDomExpr(scope, expr);
        return ECall(appendChild, [compiledExpr]).toExpr();
    }

    private static function forBlock(fragIdent :String, it :Expr, frag :Expr, callAppendChild :Expr) : Expr
    {
        var forExpr = EFor(it, callAppendChild)
            .toExpr();
        var returnExpr = fragIdent
            .createDefIdent()
            .toExpr()
            .createDefReturn()
            .toExpr();
        return [frag, forExpr, returnExpr].createDefBlock().toExpr();
    }
}
#end