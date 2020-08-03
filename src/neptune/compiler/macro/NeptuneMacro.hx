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
        var fields = Context.getBuildFields();
        var scope = new Scope();
        var func = MetaTransformer.transformField.bind(compileMarkup, scope);
        return fields.map(func);
    }

    public static function compileMarkup(scope :Scope, e :Expr) : Expr
    {
        var xml = switch e.expr {
            case EConst(c): switch c {
                case CString(s, _): s;
                case _: throw "err";
            }
            case _:
                throw "err";
        }

        var start = Context.getPosInfos(e.pos).min;
        var filename = Context.getPosInfos(Context.currentPos()).file;
        var result = Parser.parse(new Scanner(filename, xml, start));

        return handleTree(scope, result);
    }

    public static function handleTree(scope :Scope, current :DomAST) : Expr
    {
        return switch current {
            case DomText(string):
                [string.cleanWhitespace().createDefString().toExpr()]
                    .createDefCall("createText")
                    .toExpr();

            case DomExpr(expr):
                handleDomExpr(scope, expr); 
                
            case DomElement(tag, attrs, children): {
                var cExpr = children.map(handleTree.bind(scope))
                    .createDefArrayDecl()
                    .toExpr();
                var element = [tag.createDefString().toExpr()]
                    .createDefCall("createElement")
                    .toExpr();
                [element, cExpr]
                    .createDefCall("addChildren")
                    .toExpr();
            }
        }
    }


    public static function handleDomExpr(scope :Scope, expr :Expr) : Expr
    {
        return switch expr.expr {
            case EConst(c):
                switch c {
                    case CIdent(s):
                        var newIdent = createIdent();
                        var text = [s.createDefIdent().toExpr()]
                            .createDefCall("createText");
                        var varExpr = text.toExpr().createDefVar(newIdent).toExpr();
                        scope.addScopedExpr(s, varExpr);
                        var traceExpr = [newIdent.createDefIdent().toExpr()].createDefCall("trace").toExpr();
                        scope.addScopedExpr(s, traceExpr);

                        expr.updateDef(newIdent.createDefIdent());
                    case _:
                        throw "not implmented yet";
                }
            case EMeta(s, e):
                compileMarkup(scope, e);
            case _:
                throw "not implmented yet";
        }
    }

    private static var _index = 0;
    private static function createIdent() : String
    {
        return 'var_${_index++}';
    }
}

#end