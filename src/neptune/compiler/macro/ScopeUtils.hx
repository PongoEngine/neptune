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
import haxe.macro.Printer;

/**
 * This is a pretty costly util. Look into a DS for better lookups.
 */
class ScopeUtils
{
    public static function insertExprs(block :Array<Expr>, initializers :Array<Expr>, setter :Expr) : Void
    {
        #if debugBlock
            var p = new Printer();
            var blockStr = "\n\n--start-block--\n" + p.printExprs(block, "\n") + "\n--end-block--\n";
            trace(blockStr);
        #end

        for(initializer in initializers) {
            var index = getIndex(initializer, block);
            block.insert(index, initializer);
        }

        var index = getIndex(setter, block);
        block.insert(index, setter);

        #if debugBlock
            var initializersStr = "\n\n--start-initializers--\n" + p.printExprs(initializers, "\n") + "\n--end-initializers--\n";
            trace(initializersStr);
        #end
    }

    private static function getIndex(initializer :Expr, block :Array<Expr>) : Int
    {
        var lastIndex = 0;
        switch initializer.expr {
            case EVars(vars): {
                var idents = getIdents(vars);
                for(ident in idents) {
                    var index = getExprIndex(ident, block);
                    if(index > lastIndex) {
                        lastIndex = index;
                    }
                }
            }
            case _:
                var idents = [];
                getIdent(initializer, idents);
                for(ident in idents) {
                    var index = getExprIndex(ident, block);
                    if(index > lastIndex) {
                        lastIndex = index;
                    }
                }
        }
        return lastIndex;
    }

    private static function getIdents(vars :Array<Var>) : Array<String>
    {
        var idents = [];
        for(var_ in vars) {
            getIdent(var_.expr, idents);
        }
        return idents;
    }

    private static function getIdent(expr :Expr, idents :Array<String>) : Void
    {
        if(expr == null) return;
        switch expr.expr {
            case EConst(c):
                switch c {
                    case CIdent(s): idents.push(s);
                    case _: throw "not implemented yet";
                }
            case ETernary(econd, eif, eelse):
                getIdent(econd, idents);
                getIdent(eif, idents);
                getIdent(eelse, idents);
            case ECall(e, params):
                getIdent(e, idents);
                for(param in params) {
                    getIdent(param, idents);
                }
            case EBinop(op, e1, e2):
                getIdent(e1, idents);
                getIdent(e2, idents);
            case EFunction(kind, f):
                getIdent(f.expr, idents);
            case EBlock(exprs):
                for(blockexpr in exprs) {
                    getIdent(blockexpr, idents);
                }
            case _:
                throw "not implemented yet";
        }
    }

    public static function getExprIndex(ident :String, block :Array<Expr>) : Int
    {
        var index = 1;
        for(item in block) {
            switch item.expr {
                case EVars(vars):
                    if(varsContainsIdent(ident, vars)) {
                        return index;
                    }
                case _:
            }
            index++;
        }

        return 0;
    }

    private static function varsContainsIdent(ident :String, vars :Array<Var>) : Bool
    {
        for(v in vars) {
            if(v.name == ident) {
                return true;
            }
        }
        return false;
    }
}
#end