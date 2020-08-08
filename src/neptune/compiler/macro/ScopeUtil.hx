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

class ScopeUtil
{
    public static function addDeps(deps :Array<String>, expr :Expr) : Array<String>
    {
        switch expr.expr {
            case EConst(c): switch c {
                case CIdent(s): deps.push(s);
                case _: throw "not implemented yet";
            }
            case ECall(e, params):
                for(param in params) {
                    addDeps(deps, param);
                }
            case ETernary(econd, eif, eelse):
                addDeps(deps, econd);
                addDeps(deps, eif);
                addDeps(deps, eelse);
            case _:
                throw "not implemented yet";
        }
        return deps;
    }

    public static function getInsertIndex(deps :Array<String>, block :Array<Expr>) : Int
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
            if(deps.length == 0) {
                break;
            }
        }
        return deps.length == 0 ? index : -1;
    }
}

#end