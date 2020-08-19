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
        var rootFragIdent = Compile.createIdent("root_for_frag");
        var frag = createFragmentCall(rootFragIdent);
        scope.addVarExpr(frag);
        var localFor = wrapLoop(fragIdent, it, forExpr);

        scope.addUpdateExpr(updateFragment(rootFragIdent, localFor));

        return createInitializer(fragIdent, rootFragIdent, localFor.copy());
    }

    private static function createInitializer(fragIdent :String, rootFragIdent :String, localFor :Array<Expr>) : Expr
    {
        localFor.push(OpAssign.createDefBinop(rootFragIdent.createDefIdent().toExpr(), fragIdent.createDefIdent().toExpr()).toExpr());
        localFor.push(rootFragIdent.createDefIdent().toExpr());
        return localFor.createDefBlock().toExpr();
    }

    private static function updateFragment(rootFragIdent :String, localFor :Array<Expr>) : Expr
    {
        return [rootFragIdent.createDefIdent().toExpr(), localFor.createDefBlock().toExpr()]
            .createDefCall("updateFragment")
            .toExpr();
    }

    private static function createForExpr(fragIdent :String, scope :Scope, expr :Expr) : Expr
    {
        var block = [];
        var child = scope.createChild(block);
        var compiledExpr = Compile.handleDomExpr(child, expr);
        var appendChild = [compiledExpr].createDefCallField(fragIdent, "appendChild").toExpr();
        block.push(appendChild);
        return block.createDefBlock().toExpr();
    }

    private static function wrapLoop(fragIdent :String, it :Expr, expr :Expr) : Array<Expr>
    {
        var frag = createFragmentCall(fragIdent);
        var fragIdentExpr = fragIdent.createDefIdent().toExpr();

        return [frag, EFor(it, expr).toExpr(), fragIdentExpr];
    }

    private static function createFragmentCall(ident :String) : Expr
    {
        return [].createDefCall("createFragment").toExpr().createDefVar(ident).toExpr();
    }
}
#end