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

class Setter
{
    public static function save(scope :Scope, expr :Expr) : Expr
    {
        return switch expr.expr {
            case EBinop(op, e1, e2): 
                switch op {
                    case OpAssign:
                        scope.saveAssignment(expr);
                        expr;
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
                        expr;
                    }
            case _:
                expr;
        }
    }
}
#end