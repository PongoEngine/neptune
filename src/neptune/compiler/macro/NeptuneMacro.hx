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
import neptune.compiler.macro.MetaTransformer.transformField;
using neptune.compiler.macro.Utils;
using haxe.macro.ExprTools;
using StringTools;

class NeptuneMacro
{
    macro static public function fromInterface():Array<Field> 
    {
        var scope = new Scope();
        var setter = new Setter();
        var transformedFields = Context.getBuildFields()
            .map(transformField.bind(compileMarkup, scope, setter));
        setter.transformAssignments();

        return transformedFields;
    }

    /**
     * Transform meta markup to dom expressions.
     * @param scope 
     * @param e 
     * @return Expr
     */
    private static function compileMarkup(scope :Scope, e :Expr) : Expr
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

    /**
     * Transform a tree of nodes to dom expressions.
     * @param scope 
     * @param node 
     * @return Expr
     */
    private static function handleTree(scope :Scope, node :DomAST) : Expr
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

                var element = [tag.createDefString().toExpr()]
                    .createDefCall("createElement")
                    .toExpr()
                    .createDefVar("elem")
                    .toExpr();
                
                var addChildren = ["elem".createDefIdent().toExpr(), cExpr]
                    .createDefCall("addChildren")
                    .toExpr();

                var addAttrs = attrs
                    .map(handleAttr.bind(scope))
                    .map(f -> f("elem".createDefIdent().toExpr()))
                    .createDefArrayDecl()
                    .toExpr();

                var ident = "elem".createDefIdent().toExpr();

                [element, addChildren, addAttrs, ident]
                    .createDefBlock()
                    .toExpr();
            }
        }
    }

    /**
     * Add attributes to an element.
     * @param scope 
     * @param attr 
     * @return Expr -> Expr
     */
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

    /**
     * Update expressions in place for dom manipulation. Also save expressions
     * that will be inserted after all scope level expressions have been updated.
     * @param scope 
     * @param expr 
     * @return Expr
     */
    private static function handleDomExpr(scope :Scope, expr :Expr) : Expr
    {
        return switch expr.expr {
            case EConst(c):
                switch c {
                    case CIdent(s):
                        switch getItemType(s, scope) {
                            case Text: {
                                var ident = createIdent();

                                var initializer = [s.createDefIdent().toExpr()]
                                    .createDefCall("createText")
                                    .toExpr()
                                    .createDefVar(ident)
                                    .toExpr();
                                    
                                var updater = [ident.createDefIdent().toExpr(), s.createDefIdent().toExpr()]
                                    .createDefCall("updateTextNode")
                                    .toExpr();

                                scope.addScopedExpr(s, initializer, updater);
                                expr.updateDef(ident.createDefIdent());
                            }
                            case Element:
                                expr;
                        }
                    case _:
                        throw "not implmented yet";
                }
            case EMeta(s, e):
                compileMarkup(scope, e);
            case _:
                throw "not implmented yet";
        }
    }

    private static var _identIndex = 0;
    private static function createIdent() : String
    {
        return 'var_${_identIndex++}';
    }

    /**
     * Get the type of field or expression. It will be used to determine the type 
     * expressions that are generated to create the html elements.
     * @param expr 
     * @return ItemType
     */
    private static function getItemType(ident :String, scope :Scope) : ItemType
    {
        return switch scope.getItem(ident) {
            case SField(field): switch field.kind {
                case FVar(t, e): throw "not implemented yet";
                case FFun(f): throw "not implemented yet";
                case FProp(get, set, t, e): throw "not implemented yet";
            }
            case SExpr(expr): getExprItemType(expr);
        }
    }

    /**
     * Get the type of expression. It will be used to determine the type expressions
     * that are generated to create the html elements.
     * @param expr 
     * @return ItemType
     */
    private static function getExprItemType(expr :Expr) : ItemType
    {
        return switch expr.expr {
            case EMeta(s, e): Element;
            case _: Text;
        }
    }
}

enum ItemType
{
    Text;
    Element;
}

#end