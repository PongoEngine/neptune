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
using neptune.compiler.macro.Utils;

class Setter
{
    public function new() : Void
    {
        _assignments = [];
    }
    
    public function saveAssignment(expr :Expr) : Void
    {
        switch expr.expr {
            case EBinop(op, e1, e2): 
                switch op {
                    case OpAssign:
                        _assignments.push(expr);
                    case OpAssignOp(op):
                        throw "not implemented yet";
                    case _:
                        expr;
                }
            case EUnop(op, postFix, e): 
                switch op {
                    case OpIncrement: 
                        throw "not implemented yet";
                    case OpDecrement:
                        throw "not implemented yet";
                    case _:
                    }
            case _:
        }
    }

    /**
     * Transform all assigment type expressions to use setters in place
     */
    public function transformAssignments() : Void
    {
        for(assignment in _assignments) {
            switch assignment.expr {
                case EBinop(op, e1, e2):
                    switch op {
                        case OpAssign:
                            switch e1.expr {
                                case EConst(c):
                                    switch c {
                                        case CIdent(s):
                                            assignment.expr = [e2].createDefCall('set_${s}');
                                        case _:
                                            throw "not implemented yet";
                                    }
                                case EField(e, field):
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
    }

    public static function createSetter(ident :String, updateExpr :Expr) : Expr
    {
        var argName = 'new_${ident}';
        var assignmentExpr = OpAssign.createDefBinop(ident.createDefIdent().toExpr(), argName.createDefIdent().toExpr())
            .toExpr();

        var blockExpr = [assignmentExpr, updateExpr]
            .createDefBlock()
            .toExpr();

        return blockExpr.createDefFunc('set_${ident}', [argName])
            .toExpr();
    }

    private var _assignments :Array<Expr>;
}
#end