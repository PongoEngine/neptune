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
using neptune.compiler.Utils;

class NewFields
{
    public var topLevel :Array<{name :String, expr :Expr}>;
    public var setterFns :Array<Expr>;

    public function new() : Void
    {
        this.topLevel = [];
        this.setterFns = [];
    }
}

#if macro
class Compiler
{

    

    public static function compile(fields :Map<String, NewFields>, child :DomAST) : Expr
    {
        return switch child {
            case DomText(text):
                return compileText(text);
            case DomTextExpr(expr):
                return compileTextExpr(fields, expr);
            case DomElement(tag, attrs, children):
                return compileElement(fields, tag, attrs, children);
        }
    }

    static function getFieldsArray(ident :String, fields :Map<String, NewFields>) : NewFields
    {
        if(!fields.exists(ident)) {
            fields.set(ident, new NewFields());
        }
        return fields.get(ident);
    }

    static function createDep(fields :Map<String, NewFields>, expr :Expr) : String
    {
        return switch expr.expr {
            case EConst(c): switch c {
                case CIdent(s):
                    var fields = getFieldsArray(s, fields);
                    var fieldName = Utils.createFieldName();
                    return fieldName;
                case _: 
                    throw "not implemented yet!";
            }
            case EField(_): 
                throw "not implemented yet!";
            case ECall(e, params):
                throw "not implemented yet!";
            case EBinop(op, e1, e2):
                throw "not implemented yet!";
            case _:
                throw "not implemented yet!";
        }
    }

    static function compileTextExpr(fields :Map<String, NewFields>, expr :Expr) : Expr
    {
        return switch expr.expr {
            case EConst(c): switch c {
                case CIdent(s):
                    var fieldName = createDep(fields, expr);
                    var fields = getFieldsArray(s, fields);

                    var func = [expr]
                        .createCall("createText");

                    fields.topLevel.push({name:fieldName,expr:func});
                    fields.setterFns.push([fieldName.createExprIdent()].createCall("updateTextNode"));
                    fieldName.createExprIdent();
                case _: 
                    throw "not implemented";
            }
            case EField(_): 
                expr;
            case ECall(e, params):
                expr;
            case EBinop(op, e1, e2):
                var fieldName1 = createDep(fields, e1);
                var fieldName2 = createDep(fields, e2);
                trace(fieldName1, fieldName2);
                // throw "not supported";
                expr;
            case _:
                throw "not supported";
        }
    }

    static function compileText(value :String) : Expr
    {
        var strExpr = value
            .cleanWhitespace()
            .createExprString();
        return [strExpr].createCall("createText");
    }

    static function compileElement(fields :Map<String, NewFields>, tag :String, attrs:Array<Attr>, children:Array<DomAST>) : Expr
    {
        var root = [tag.createExprString()].createCall("createElement");
        var block :Array<Expr> = [];
        block.push(root.createVar(tag));

        for(attr in attrs) {
            block.push(createAttr(attr, tag));
        }

        for(child in children) {
            block.push(createChild(fields, tag, child));
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

    static function createChild(fields :Map<String, NewFields>, tag :String, child :DomAST) : Expr
    {
        var cexpr = compile(fields, child);
        return [tag.createExprIdent(), cexpr].createCall("addChild");
    }
}
#end