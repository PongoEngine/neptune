package neptune.compiler.dom;

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

import neptune.compiler.dom.Token;
import haxe.macro.Context;
using neptune.compiler.dom.Scanner.ScannerTools;

#if macro
class Parser
{
    public static function parse(scanner :Scanner) : DomAST
    {
        var nodes = parseNodes(scanner);
        assertThat(nodes.length == 1);
        return nodes[0];
    }

    public static function parseNode(scanner :Scanner) : DomAST
    {
        var token :Token = scanner.peek();
        return switch token {
            case ELEMENT_OPENED: 
                parseElement(scanner);
            case _:
                parseText(scanner);
        }
    }

    static function parseNodes(scanner :Scanner) : Array<DomAST>
    {
        var nodes = [];
        while(scanner.hasNext() && !isClosing(scanner)) {
            nodes.push(parseNode(scanner));
        }
        return nodes;
    }

    static function isClosing(scanner :Scanner) :Bool 
    {
        var end = scanner.peek() + scanner.peekDouble();
        return end == "</";
    }

    static function parseElement(scanner :Scanner) : DomAST
    {
        assertToken(scanner.next(), Token.ELEMENT_OPENED);
        scanner.consumeWhile(ScannerTools.isWhitespace);
        var tagname = parseTagname(scanner);
        var attrs = parseAttrs(scanner);
        assertToken(scanner.next(), Token.ELEMENT_CLOSED);
        var children = parseNodes(scanner);
        assertToken(scanner.next(), Token.ELEMENT_OPENED);
        assertToken(scanner.next(), Token.FORWARD_SLASH);
        assertThat(parseTagname(scanner) == tagname);
        assertToken(scanner.next(), Token.ELEMENT_CLOSED);
        return DomElement(tagname,attrs,children);
    }

    static function parseText(scanner :Scanner) : DomAST
    {
        while(scanner.hasNext() && scanner.peek() != Token.ELEMENT_OPENED) {
            var t :Token = scanner.peek();
            switch t {
                case Token.CURLY_BRACE_OPENED: {
                    assertToken(scanner.next(), Token.CURLY_BRACE_OPENED);
                    var min = scanner.curIndex + scanner.startingIndex;
                    var exprStr = parseExpr(scanner);
                    var max = scanner.curIndex + scanner.startingIndex;
                    var pos = Context.makePosition({file: scanner.filename, min:min, max:max});
                    var expr = Context.parse('{${exprStr};}', pos);
                    assertToken(scanner.next(), Token.CURLY_BRACE_CLOSED);
                    return DomExpr(expr);
                }
                case _: {
                    return DomText(scanner.consumeWhile((str) -> {
                        scanner.hasNext() && str != Token.ELEMENT_OPENED && str != Token.CURLY_BRACE_OPENED;
                    }));
                }
            }
        }

        throw "err";
    }

    static function parseExpr(scanner :Scanner) : String
    {
        var start = scanner.peek();
        var curlys = 1;
        var exprStr = scanner.consumeWhile((str) -> {
            if(str == Token.CURLY_BRACE_OPENED) {
                curlys++;
            }
            else if(str == Token.CURLY_BRACE_CLOSED) {
                curlys--;
            }
            var curlyLogic = curlys == 0 ? str != Token.CURLY_BRACE_CLOSED : true;
            return scanner.hasNext() && curlyLogic;
        });

        return exprStr;
    }

    static function parseTagname(scanner :Scanner) : String
    {
        return scanner.consumeWhile((str) -> {
            return scanner.hasNext() && str.isAlphaNumeric();
        });
    }

    static function parseAttrs(scanner :Scanner) : Array<Attr>
    {
        var attrs = [];
        while(scanner.hasNext() && scanner.peek() != Token.ELEMENT_CLOSED) {
            scanner.consumeWhile(ScannerTools.isWhitespace);
            attrs.push(parseAttr(scanner));
        }
        return attrs;
    }

    static function parseAttr(scanner :Scanner) : Attr
    {
        var name = parseTagname(scanner);
        assertToken(scanner.next(), Token.EQUALS);
        var value = parseAttrValue(scanner);
        return {name:name,value:value};
    }

    static function parseAttrValue(scanner :Scanner) : DomAttr
    {
        var token :Token = scanner.peek();
        return switch token {
            case Token.DBL_QUOTE: parseAttrValueString(scanner);
            case Token.CURLY_BRACE_OPENED: parseAttrValueLogic(scanner);
            case _: assertThat(false);
        }
    }

    static function parseAttrValueString(scanner :Scanner) : DomAttr
    {
        assertToken(scanner.next(), Token.DBL_QUOTE);
        var attrValue = scanner.consumeWhile((str) -> {
            return scanner.hasNext() && !(str == '"' || str == "}");
        });
        assertToken(scanner.next(), Token.DBL_QUOTE);
        return AttrText(attrValue);
    }

    static function parseAttrValueLogic(scanner :Scanner) : DomAttr
    {
        assertToken(scanner.next(), Token.CURLY_BRACE_OPENED);
        var min = scanner.curIndex + scanner.startingIndex;
        var attrValue = scanner.consumeWhile((str) -> {
            return scanner.hasNext() && !(str == '"' || str == "}");
        });
        var max = scanner.curIndex + scanner.startingIndex;
        assertToken(scanner.next(), Token.CURLY_BRACE_CLOSED);
        var pos = Context.makePosition({file: scanner.filename, min:min, max:max});
        var expr = Context.parse(attrValue, pos);
        return AttrExpr(expr);
    }

    static function assertToken(value :String, token :Token) : Dynamic
    {
        return value == token ? null : (throw '${value} is not in ${token}');
    }

    static function assertThat(value :Bool) : Dynamic
        return value ? null : throw "err";
}
#end

enum DomAttr
{
    AttrText(string :String);
    AttrExpr(expr :haxe.macro.Expr);
}

typedef Attr = {name :String, value :DomAttr};

enum DomAST
{
    DomText(string :String);
    DomExpr(expr :haxe.macro.Expr);
    DomElement(tag:String, attrs:Array<Attr>, children :Array<DomAST>);
}