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
import neptune.compiler.dom.Parser.DomAST;
import neptune.compiler.dom.Parser.Attr;
using neptune.compiler.macro.Utils;

#if macro
class Compiler
{
    public static function compile(deps :Deps, child :DomAST) : Expr
    {
        return switch child {
            case DomText(text):
                return compileText(text);
            case DomTextExpr(expr):
                return compileTextExpr(deps, expr);
            case DomElement(tag, attrs, children):
                return compileElement(deps, tag, attrs, children);
        }
    }

    static function getIdentifier(expr :Expr) : String
    {
        return switch expr.expr {
            case EConst(c): switch c {
                case CIdent(ident): ident;
                case _: null;
            }
            case _: null;
        }
    }

    static function compileTextExpr(deps :Deps, expr :Expr) : Expr
    {
        return switch expr.expr {
            case EConst(c):
                var fieldName = Utils.createFieldName();
                var setterFn = [fieldName.createExprIdent(), expr].createCall("updateTextNode");
                deps.pushTopLevel(fieldName, [expr].createCall("createText"));
                saveDependency(deps, expr, setterFn);
                fieldName.createExprIdent();
            case EField(_): 
                throw "not implemented";
            case ECall(e, params):
                expr;
            case EBinop(op, e1, e2):
                var fieldName = Utils.createFieldName();
                var setterFn = [fieldName.createExprIdent(), expr].createCall("updateTextNode");
                deps.pushTopLevel(fieldName, [expr].createCall("createText"));
                saveDependency(deps, expr, setterFn);
                fieldName.createExprIdent();
            case EParenthesis(e):
                var fieldName = Utils.createFieldName();
                var setterFn = [fieldName.createExprIdent(), expr].createCall("updateTextNode");
                deps.pushTopLevel(fieldName, [expr].createCall("createText"));
                saveDependency(deps, expr, setterFn);
                fieldName.createExprIdent();
            case ETernary(econd, eif, eelse):
                var fieldName = Utils.createFieldName();
                var setterFn = [fieldName.createExprIdent(), expr].createCall("updateTextNode");
                deps.pushTopLevel(fieldName, [expr].createCall("createText"));
                saveDependency(deps, expr, setterFn);
                fieldName.createExprIdent();
            case EMeta(s, e):
                NeptuneMacro.compileMarkup(deps, e);
            case _:
                // trace(expr.expr);
                // NeptuneMacro.compileMarkup(deps, )
                throw "not supported";
        }
    }

    static function saveDependency(deps :Deps, expr :Expr, setterFn :Expr) : Void
    {
        return switch expr.expr {
            case EConst(c): switch c {
                case CIdent(ident):
                    deps.pushSetter(ident, setterFn);
                case _:
                    //real constant
            }
            case EField(e, field): 
                saveDependency(deps, e, setterFn);
            case ECall(e, params):
                // throw "not implemented";
                saveDependency(deps, e, setterFn);
            case EBinop(op, e1, e2):
                saveDependency(deps, e1, setterFn);
                saveDependency(deps, e2, setterFn);
            case EParenthesis(e):
                saveDependency(deps, e, setterFn);
            case ETernary(econd, eif, eelse):
                saveDependency(deps, econd, setterFn);
                saveDependency(deps, eif, setterFn);
                saveDependency(deps, eelse, setterFn);
            case _:
                throw "not implemented";
        }
    }

    static function compileText(value :String) : Expr
    {
        var strExpr = value
            .cleanWhitespace()
            .createExprString();
        return [strExpr].createCall("createText");
    }

    static function compileElement(deps :Deps, tag :String, attrs:Array<Attr>, children:Array<DomAST>) : Expr
    {
        var root = [tag.createExprString()].createCall("createElement");
        var block :Array<Expr> = [];
        block.push(root.createVar(tag));

        for(attr in attrs) {
            block.push(createAttr(attr, tag));
        }

        for(child in children) {
            block.push(createChild(deps, tag, child));
        }

        block.push(tag.createExprIdent());

        return {
            expr: EBlock(block),
            pos: Context.currentPos()
        }
    }

    static function createAttr(attr :Attr, tag :String) : Expr
    {
        var ident = (attr.name == "onclick")
            ? "addAttrEvent"
            : "addAttr";
        return {
            expr: ECall(ident.createExprIdent(), [
                tag.createExprIdent(), 
                attr.name.createExprString(),
                {
                    expr: switch attr.value {
                        case AttrText(string): EConst(CString(string));
                        case AttrExpr(expr): expr.expr;
                    },
                    pos: Context.currentPos()
                }
            ]),
            pos: Context.currentPos()
        }
    }

    static function createChild(deps :Deps, tag :String, child :DomAST) : Expr
    {
        var cexpr = compile(deps, child);
        return [tag.createExprIdent(), cexpr].createCall("addChild");
    }
}
#end