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
import haxe.macro.Context;
import haxe.macro.Expr;
import neptune.compiler.dom.Scanner;
import neptune.compiler.dom.Parser;
import neptune.compiler.macro.scope.Scope;
using neptune.compiler.macro.ExprUtils;
using neptune.util.NStringUtils;

class CompileDom
{
    public static function compileMeta(expr :Expr) : DomAST
    {
        var str :String = switch expr.expr {
            case EConst(c): switch c {
                case CString(s, kind):
                    s;
                case _:
                    throw "err";
            }
            case _: 
                throw "err";
        }

        var start = Context.getPosInfos(expr.pos).min;
        var filename = Context.getPosInfos(Context.currentPos()).file;
        return Parser.parse(new Scanner(filename, str, start));
    }

    public static function handleTree(scope :Scope, node :DomAST) : Expr
    {
        return switch node {
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

                var ident = createIdent();
                var element = [tag.createDefString().toExpr()]
                    .createDefCall("createElement")
                    .toExpr()
                    .createDefVar(ident)
                    .toExpr();
                
                var addChildren = [ident.createDefIdent().toExpr(), cExpr]
                    .createDefCall("addChildren")
                    .toExpr();

                var addAttrs = attrs
                    .map(handleAttr.bind(scope))
                    .map(f -> f(ident.createDefIdent().toExpr()))
                    .createDefArrayDecl()
                    .toExpr();

                var ident = ident.createDefIdent().toExpr();

                [element, addChildren, addAttrs, ident]
                    .createDefBlock()
                    .toExpr();
            }
        }
    }

    private static function handleAttr(scope :Scope, attr :Attr) : Expr -> Expr
    {
        return switch attr.value {
            case AttrText(value): (element) -> {
                var attrName = attr.name.createDefString().toExpr();
                var attrValue = value.createDefString().toExpr();
                return [element, attrName, attrValue]
                    .createDefCall("addAttr")
                    .toExpr();
            }
            case AttrExpr(expr): (element) -> {
                if(attr.name == "onclick") {
                    return [element, expr]
                        .createDefCall("onclick")
                        .toExpr();
                }
                else {
                    var attrName = attr.name.createDefString().toExpr();
                    return [element, attrName, expr]
                        .createDefCall("addAttr")
                        .toExpr();
                }
            }
        }
    }

    private static function handleDomExpr(scope :Scope, expr :Expr) : Expr
    {
        return switch expr.expr {
            case EConst(c): switch c {
                case CIdent(s):
                    if(scope.isMeta(s)) {
                        expr;
                    }
                    else {
                        var ident = createIdent();
                        var createTextVar = [expr].createDefCall("createText").toExpr()
                            .createDefVar(ident)
                            .toExpr();
                        scope.addVar(createTextVar);

                        var update = [ident.createDefIdent().toExpr(), s.createDefIdent().toExpr()]
                            .createDefCall("updateTextNode")
                            .toExpr();

                        scope.addUpdate(update);
                        ident.createDefIdent().toExpr();
                    }
                case _:
                    [expr].createDefCall("createText").toExpr();
            }

            case ETernary(econd, eif, eelse):
                var left = handleDomExpr(scope, eif);
                var right = handleDomExpr(scope, eelse);
                var ident = createIdent();
                var createTernaryVar = ETernary(econd, left, right).toExpr()
                    .createDefVar(ident)
                    .toExpr();
                scope.addVar(createTernaryVar);

                var update = [econd, left, right]
                    .createDefCall("updateParent")
                    .toExpr();
                    
                scope.addUpdate(update);
                ident.createDefIdent().toExpr();

            case ECall(e, params):
                expr;

            case EFor(it, expr):
                transformForLoop(it, handleDomExpr(scope, expr));

            case EMeta(s, e):
                var dom = CompileDom.compileMeta(e);
                return CompileDom.handleTree(scope, dom);

            case _:
                throw "not implemented yet";
        }
    }

    private static var _identIndex = 0;
    private static function createIdent() : String
    {
        return 'var_${_identIndex++}';
    }

    private static function transformForLoop(it :Expr, expr :Expr) : Expr
    {
        var frag = [].createDefCall("createFragment").toExpr()
            .createDefVar("frag")
            .toExpr();

        var appendChild = EField("frag".createDefIdent().toExpr(), "appendChild").toExpr();
        var callAppendChild = ECall(appendChild, [expr]).toExpr();
            
        var forExpr = EFor(it, callAppendChild).toExpr();
        var returnExpr = "frag".createDefIdent().toExpr();
        var fullBlock = [frag, forExpr, returnExpr].createDefBlock().toExpr();

        return fullBlock;
    }
}

#end