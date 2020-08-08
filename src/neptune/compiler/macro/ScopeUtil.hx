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
using neptune.compiler.macro.ExprUtils;

class ScopeUtil
{
    public static function getInsertIndex(newExpr :ExprDeps, block :Array<Expr>) : Int
    {
        var index = 0;
        for(blockItem in block) {
            switch blockItem.expr {
                case EVars(vars): 
                    for(var_ in vars) {
                        if(newExpr.existsDep(var_.name)) {
                            newExpr.removeDep(var_.name);
                        }
                    }
                case _:
            }
            index++;
            if(newExpr.isSatisfied()) {
                break;
            }
        }
        return newExpr.isSatisfied() ? index : -1;
    }

    public static function addDeps(expr :Expr, deps :Array<String>) : Void
    {
        switch expr.expr {
            case EConst(c): switch c {
                case CIdent(s): deps.push(s);
                case _: throw "not implemented yet";
            }
            case ECall(e, params):
                for(param in params) {
                    addDeps(param, deps);
                }
            case _:
                throw "not implemented yet";
        }
    }

    public static function createSetter(ident :String, updateExpr :Expr) : Expr
    {
        var argName = 'new_${ident}';
        var assignmentExpr = OpAssign.createDefBinop(ident.createDefIdent().toExpr(), argName.createDefIdent().toExpr())
            .toExpr();

        return [assignmentExpr, updateExpr]
            .createDefBlock()
            .toExpr()
            .createDefFunc('set_${ident}', [argName])
            .toExpr();
    }
}

#end