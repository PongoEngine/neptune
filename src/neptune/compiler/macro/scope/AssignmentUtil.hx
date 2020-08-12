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
using neptune.compiler.macro.ExprUtils;
using neptune.util.Set;
using neptune.compiler.macro.scope.DepsUtil;

class AssignmentUtil
{
    public static function handleAssignment(assignment :Expr) : Void
    {
        switch assignment.expr {
            case EBinop(op, e1, e2):
                switch op {
                    case OpAssign:
                        switch e1.expr {
                            case EConst(c): switch c {
                                case CIdent(s):
                                    assignment.expr = [e2].createDefCall('set_${s}');
                                case _:
                            }
                            case _:
                        }
                    case OpAssignOp(op):
                        switch e1.expr {
                            case EConst(c): switch c {
                                case CIdent(s):
                                    var binopExpr = EBinop(op, e1, e2).toExpr();
                                    assignment.expr = [binopExpr].createDefCall('set_${s}');
                                case _:
                            }
                            case _:
                        }
                    case _:
                }
            case _:
        }
    }

    public static function createSetterTemp(ident :String) : Expr
    {
        var block = []
            .createDefBlock()
            .toExpr();
        var setter = block.createDefFuncAnon(["val"])
            .toExpr()
            .createDefVar('set_${ident}')
            .toExpr();

        return setter;
    }

    public static function createSetter(ident :String, updates :Array<Expr>) : Expr
    {
        var assignment = createAssignment(ident);

        var block = [assignment].concat(updates)
            .createDefBlock()
            .toExpr();
        var setter = block.createDefFuncAnon(["val"])
            .toExpr();

        return OpAssign.createDefBinop('set_${ident}'.createDefIdent().toExpr(), setter)
            .toExpr();
    }

    private static function createAssignment(ident :String) : Expr
    {
        var this_ = ident
            .createDefIdent()
            .toExpr();
        var that = 'val'
            .createDefIdent()
            .toExpr();
        return OpAssign.createDefBinop(this_, that)
            .toExpr();
    }
}

#end