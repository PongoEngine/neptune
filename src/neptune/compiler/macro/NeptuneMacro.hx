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

import haxe.macro.Context;
import haxe.macro.Expr;
import neptune.compiler.dom.Scanner;
import neptune.compiler.dom.Parser;
using neptune.compiler.macro.Utils;
using haxe.macro.ExprTools;
using StringTools;

#if macro
class NeptuneMacro
{
    macro static public function fromInterface():Array<Field> 
    {
        var scope = new Scope();
        var func = MetaTransformer.transformField.bind(compileMarkup, scope);
        var fields = Context.getBuildFields()
            .map(func);

        return fields;
    }

    public static function compileMarkup(scope :Scope, e :Expr) : Expr
    {
        var xml = switch e.expr {
            case EConst(c): switch c {
                case CString(s, _): s;
                case _: throw "err";
            }
            case _: throw "err";
        }

        var start = Context.getPosInfos(e.pos).min;
        var filename = Context.getPosInfos(Context.currentPos()).file;
        var result = Parser.parse(new Scanner(filename, xml, start));
        handleTree(scope, null, result);

        return {
            pos: e.pos,
            expr: EConst(CString(xml))
        };
    }

    public static function handleTree(scope :Scope, parent :Null<DomAST>, current :DomAST) : Void
    {
        switch current {
            case DomText(string):
            case DomExpr(expr):
                handleExpr(scope, parent, current, expr); 
            case DomElement(tag, attrs, children): {
                for(child in children) {
                    handleTree(scope, current, child);
                }
            }
        }
    }


    public static function handleExpr(scope :Scope, parent :Null<DomAST>, current :DomAST, expr :Expr) : Void
    {
        switch expr.expr {
            case EConst(c):
                switch c {
                    case CIdent(s):
                        // switch 
                        // var item = scope.get(s);
                        // if(item != null) {
                        //     switch item {
                        //         case SField(field):
                        //         case SExpr(expr): switch expr.expr {
                        //             case EConst(c): switch c {
                        //                 case CInt(v):
                        //                     expr.expr =  EConst(CInt("200"));
                        //                 case _:
                        //             }
                        //             case _:
                        //         }
                        //     }
                        // }
                        // trace(scope.get(s));
                        trace(s, scope.exists(s));
                    case _:
                }
            case _:
        }
    }
}

#end