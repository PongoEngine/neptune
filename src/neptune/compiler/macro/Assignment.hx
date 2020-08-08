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
using neptune.compiler.macro.scope.ScopeUtil;

class Assignment
{
    public var deps (default, null) :Array<String>;

    public function new(ident :String, expr :Expr, deps :Array<String>) : Void
    {
        _ident = ident;
        _expr = expr;
        this.deps = deps;
    }

    public function createSetter() : Expr
    {
        return _expr.createDefFunc('set_${_ident}', ["hi"])
            .toExpr();
    }

    public static function saveAssignment(expr :Expr) : Assignment
    {
        return switch expr.expr {
            case EBinop(op, e1, e2):
                switch op {
                    case OpAssign: switch e1.expr {
                        case EConst(c): switch c {
                            case CIdent(s):
                                new Assignment(s, expr, [].findDeps(e2));
                            case _:
                                throw "not implemented yet";
                        }
                        case _:
                            throw "not implemented yet";
                    }
                    case _:
                        throw "not implemented yet";
                }
            case _:
                throw "not implemented yet";
        }
    }

    private var _ident :String;
    private var _expr :Expr;
}
#end