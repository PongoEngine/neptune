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
        var fragArrayIdentGlobal = Compile.createIdent("for_frag_array_g");
        var fragArrayIdentLocal = Compile.createIdent("for_frag_array_l");
        var forExpr = createForExpr(fragIdent, fragArrayIdentLocal, scope, expr);
        var fragArray = [].createDefArrayDecl().toExpr().createDefVar(fragArrayIdentGlobal).toExpr();
        scope.addVarExpr(fragArray);

        scope.addUpdateExpr(createUpdater(fragIdent, fragArrayIdentGlobal, fragArrayIdentLocal, it, forExpr));

        return createInitializer(fragIdent, fragArrayIdentGlobal, fragArrayIdentLocal, it, forExpr);
    }

    private static function updateFragment(fragArrayIdentGlobal :String) : Expr
    {
        return [fragArrayIdentGlobal.createDefIdent().toExpr()].createDefCall("trace").toExpr();
    }

    private static function createForExpr(fragIdent :String, fragArrayIdentLocal :String, scope :Scope, expr :Expr) : Expr
    {
        var block = [];
        var child = scope.createChild(block);
        var compiledExpr = Compile.handleDomExpr(child, expr);
        var pushItem = [compiledExpr].createDefCallField(fragArrayIdentLocal, "push").toExpr();
        block.push(pushItem);

        return block.createDefBlock().toExpr();
    }

    private static function createInitializer(fragIdent :String, fragArrayIdentGlobal :String, fragArrayIdentLocal :String, it :Expr, expr :Expr) : Expr
    {
        var fragArrayLocal = [].createDefArrayDecl().toExpr().createDefVar(fragArrayIdentLocal).toExpr();
        var frag = [].createDefCall("createFragment").toExpr().createDefVar(fragIdent).toExpr();
        var opAssign = OpAssign.createDefBinop(fragArrayIdentGlobal.createDefIdent().toExpr(), fragArrayIdentLocal.createDefIdent().toExpr()).toExpr();
        var pushToFrag = [fragIdent.createDefIdent().toExpr(), fragArrayIdentGlobal.createDefIdent().toExpr()].createDefCall("pushToFrag").toExpr();
        var fragIdentExpr = fragIdent.createDefIdent().toExpr();

        return [fragArrayLocal, EFor(it, expr).toExpr(), frag, opAssign, pushToFrag, fragIdentExpr].createDefBlock().toExpr();
    }

    private static function createUpdater(fragIdent :String, fragArrayIdentGlobal :String, fragArrayIdentLocal :String, it :Expr, expr :Expr) : Expr
    {
        var fragArrayLocal = [].createDefArrayDecl().toExpr().createDefVar(fragArrayIdentLocal).toExpr();
        var updateFragment = [fragArrayIdentGlobal.createDefIdent().toExpr(), fragArrayIdentLocal.createDefIdent().toExpr()].createDefCall("updateFragment").toExpr();

        return [fragArrayLocal, EFor(it, expr).toExpr(), updateFragment].createDefBlock().toExpr();
    }
}
#end