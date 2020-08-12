package neptune.compiler.macro.compile;

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

class Compile
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

                var ident = createIdent('element_${tag}');
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

    public static function handleDomExpr(scope :Scope, original :Expr) : Expr
    {
        return switch original.expr {
            case EConst(c):
                CompileEConst.compile(scope, original, c);
            case EArray(e1, e2):
                CompileEArray.compile(scope, original, e1, e2);

            case EBinop(op, e1, e2):
                CompileEBinop.compile(scope, original, e1, e2);

            case EParenthesis(e):
                handleDomExpr(scope, e);

            case EIf(econd, eif, eelse):
                CompileEIf.compile(scope, original, econd, eif, eelse);

            case EBlock(exprs):
                for(i in 0...exprs.length) {
                    exprs[i] = handleDomExpr(scope, exprs[i]);
                }
                original;

            case EWhile(econd, e, normalWhile):
                CompileEWhile.compile(scope, original, econd, e, normalWhile);
            
            case EFor(it, expr):
                CompileEFor.compile(scope, original, it, expr);

            case EVars(vars):
                for(i in 0...vars.length) {
                    vars[i].expr = handleDomExpr(scope, vars[i].expr);
                    scope.saveVar(vars[i]);
                }
                original;

            case EMeta(s, e):
                var dom = Compile.compileMeta(e);
                Compile.handleTree(scope, dom);

            case EArrayDecl(values):
                CompileEArrayDecl.compile(scope, original, values);

            case EUnop(op, postFix, e):
                original;

            case _:
                throw "not implemented yet";
        }
    }

    private static var _identIndex = 0;
    public static function createIdent(name :String) : String
    {
        return '${name}_${_identIndex++}';
    }
}

#end