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
import neptune.compiler.dom.Parser;
import neptune.compiler.macro.scope.Scope;
using neptune.compiler.macro.ExprUtils;
using neptune.util.NStringUtils;

class CompileDom
{

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
                    var ident = createIdent();
                    var createTextVar = [expr].createDefCall("createText").toExpr()
                        .createDefVar(ident)
                        .toExpr();
                    scope.newVar(createTextVar);

                    var update = [ident.createDefIdent().toExpr(), s.createDefIdent().toExpr()]
                        .createDefCall("updateTextNode")
                        .toExpr();

                    scope.addUpdate(update);
                    
                    ident.createDefIdent().toExpr();
                case _:
                    throw "not implemented yet";
            }
            case ETernary(econd, eif, eelse):
                var left = handleDomExpr(scope, eif);
                var right = handleDomExpr(scope, eelse);
                var ident = createIdent();

                var createTernaryVar = ETernary(econd, left, right).toExpr()
                    .createDefVar(ident)
                    .toExpr();
                scope.newVar(createTernaryVar);

                ident.createDefIdent().toExpr();
            case _: 
                throw "not implemented yet";
        }
    }

    private static var _identIndex = 0;
    private static function createIdent() : String
    {
        return 'var_${_identIndex++}';
    }
}

#end