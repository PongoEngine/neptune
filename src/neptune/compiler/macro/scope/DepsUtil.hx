package neptune.compiler.macro.scope;

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

class DepsUtil
{
    public static function findDeps(deps :Deps, expr :Expr) : Deps
    {
        if(expr == null) deps;
        switch expr.expr {
            case EConst(c): switch c {
                case CIdent(s): deps.set(s);
                case _:
            }
            case ECall(e, params):
                for(param in params) {
                    findDeps(deps, param);
                }
            case ETernary(econd, eif, eelse):
                findDeps(deps, econd);
                findDeps(deps, eif);
                findDeps(deps, eelse);
            case EBinop(op, e1, e2):
                findDeps(deps, e1);
                findDeps(deps, e2);
            case EUnop(op, postFix, e):
                findDeps(deps, e);
            case EFunction(kind, f):
                findDeps(deps, f.expr);
                for(arg in f.args) {
                    deps.remove(arg.name);
                }
            case EBlock(exprs):
                for(expr in exprs) {
                    findDeps(deps, expr);
                }
            case EArray(e1, e2):
                findDeps(deps, e1);
                findDeps(deps, e2);
            case EIf(econd, eif, eelse):
                findDeps(deps, eif);
                findDeps(deps, eelse);
            case EVars(vars):
                for(var_ in vars) {
                    findDeps(deps, var_.expr);
                }
            case EArrayDecl(values):
                for(value in values) {
                    findDeps(deps, value);
                }
            case _:
                trace(expr.expr);
                throw "not implemented yet";
        }
        return deps;
    }

    public static function getInsertIndex(deps :Deps, block :Array<Expr>) : Int
    {
        var index = 0;
        for(blockItem in block) {
            switch blockItem.expr {
                case EVars(vars): 
                    for(var_ in vars) {
                        deps.remove(var_.name);
                    }
                case _:
            }
            index++;
            if(deps.isSatisfied()) {
                break;
            }
        }
        return deps.isSatisfied() ? index : -1;
    }
}

#end