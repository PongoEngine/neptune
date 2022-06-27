package neptune.compiler.dom;

/*
 * Copyright (c) 2022 Jeremy Meltingtallow
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
import haxe.macro.Type;
import haxe.macro.Printer;
#if macro
import neptune.compiler.macro.NeptuneMacro;
import neptune.compiler.dom.Token;
import haxe.macro.Context;
import haxe.macro.Expr;
import neptune.util.NExprUtil.*;

using neptune.compiler.dom.Scanner.ScannerTools;

class Parser {
	public static function parse(scanner:Scanner):Expr {
		var nodes = parseNodes(scanner);
		assertThat(nodes.length == 1);
		return nodes[0];
	}

	static function parseNode(scanner:Scanner):Expr {
		return switch scanner.peekToken() {
			case ELEMENT_OPENED:
				parseElementNode(scanner);
			case _:
				parseTextNode(scanner);
		}
	}

	static function parseNodes(scanner:Scanner):Array<Expr> {
		var nodes = [];
		while (scanner.hasNext() && !isClosing(scanner)) {
			nodes.push(parseNode(scanner));
		}
		return nodes;
	}

	static var elementIdentIndex = 0;

	static function parseElementNode(scanner:Scanner):Expr {
		// create element
		var elementID = 'element_${elementIdentIndex++}';
		var min = scanner.curIndex;
		assertToken(scanner.next(), Token.ELEMENT_OPENED);
		scanner.consumeWhile(ScannerTools.isWhitespace);
		var tagname = getTagname(scanner);
		var attrs = getAttributeExprs(scanner);
		assertToken(scanner.next(), Token.ELEMENT_CLOSED);
		var children = parseNodes(scanner);
		assertToken(scanner.next(), Token.ELEMENT_OPENED);
		assertToken(scanner.next(), Token.FORWARD_SLASH);
		assertThat(getTagname(scanner) == tagname);
		assertToken(scanner.next(), Token.ELEMENT_CLOSED);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);

		var newHtmlElement = makeENew(["neptune", "html"], "HtmlElement", [makeCString(tagname, pos)], pos);
		var exprs:Array<Expr> = [];
		exprs.push(makeEVars([makeVar(elementID, newHtmlElement)], pos));
		var exprIdent = makeCIdent(elementID, pos);

		// add attributes
		for (attr in attrs) {
			var ident_addAttr = makeEField(exprIdent, "addAttr", attr.pos);
			var ident_addAttr_attr_ = makeECall(ident_addAttr, [attr], attr.pos);
			exprs.push(ident_addAttr_attr_);
		}

		// add children
		for (child in children) {
			var ident_addChild = makeEField(exprIdent, "addChild", child.pos);
			var ident_addChild_child_ = makeECall(ident_addChild, [child], child.pos);
			exprs.push(ident_addChild_child_);
		}

		exprs.push(exprIdent);
		return makeEBlock(exprs, pos);
	}

	static function parseTextNode(scanner:Scanner):Expr {
		return switch scanner.peekToken() {
			case Token.CURLY_BRACE_OPENED:
				getHaxeExpr(scanner, false);
			case _:
				{
					var min = scanner.curIndex;
					var text = scanner.consumeWhile((str) -> {
						str != Token.ELEMENT_OPENED
						&& str != Token.CURLY_BRACE_OPENED;
					});
					var max = scanner.curIndex;
					var pos = scanner.makePosition(min, max);

					var textExpr = makeCString(text, pos);
					makeECall(makeCIdent("createText", textExpr.pos), [textExpr], textExpr.pos);
				}
		}
	}

	static function getAttributeExprs(scanner:Scanner):Array<Expr> {
		var attrs = [];
		while (scanner.hasNext() && scanner.peek() != Token.ELEMENT_CLOSED) {
			scanner.consumeWhile(ScannerTools.isWhitespace);
			attrs.push(getAttributeExpr(scanner));
		}
		return attrs;
	}

	static function getAttributeExpr(scanner:Scanner):Expr {
		var min = scanner.curIndex;
		var name = getTagname(scanner);
		assertToken(scanner.next(), Token.EQUALS);
		var attr = getExpr(scanner);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);
		return makeENew(["neptune", "html"], "HtmlAttribute", [makeCString(name, pos), attr], pos);
	}

	static function getExpr(scanner:Scanner):Expr {
		return switch scanner.peekToken() {
			case Token.DBL_QUOTE: getStringExpr(scanner);
			case Token.CURLY_BRACE_OPENED: getHaxeExpr(scanner, true);
			case _: assertThat(false);
		}
	}

	static function getStringExpr(scanner:Scanner):Expr {
		var min = scanner.curIndex;
		assertToken(scanner.next(), Token.DBL_QUOTE);
		var attrValue = scanner.consumeWhile((str) -> {
			return !(str == '"' || str == "}");
		});
		assertToken(scanner.next(), Token.DBL_QUOTE);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);
		return makeCString(attrValue, pos);
	}

	/**
	 * [Description]
	 * @param scanner 
	 * @param isAttribute 
	 * @return Expr
	 */
	static function getHaxeExpr(scanner:Scanner, isAttribute:Bool):Expr {
		var min = scanner.curIndex;
		assertToken(scanner.next(), Token.CURLY_BRACE_OPENED);
		var curlys = 1;
		var exprStr = scanner.consumeWhile((str) -> {
			if (str == Token.CURLY_BRACE_OPENED) {
				curlys++;
			} else if (str == Token.CURLY_BRACE_CLOSED) {
				curlys--;
			}
			var curlyLogic = curlys == 0 ? str != Token.CURLY_BRACE_CLOSED : true;
			return curlyLogic;
		});
		assertToken(scanner.next(), Token.CURLY_BRACE_CLOSED);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);

		if (isAttribute) {
			return Context.parse(exprStr, pos);
		} else {
			var expr = Context.parse('{${exprStr}}', pos);
			return NeptuneMacro.transformExpr(expr);
		}
	}

	/**
	 * Gets a tagname from opening or closing elements.
	 * @param scanner 
	 * @return String
	 */
	static function getTagname(scanner:Scanner):String {
		return scanner.consumeWhile((str) -> {
			return str == "@" || str.isAlphaNumeric();
		});
	}

	/**
	 * Checks if an element is closing. E.g. </div>
	 * @param scanner 
	 * @return Bool
	 */
	static function isClosing(scanner:Scanner):Bool {
		var end = scanner.peek() + scanner.peekDouble();
		return end == "</";
	}

	static function assertToken(value:String, token:Token):Dynamic {
		return value == token ? null : (throw '${value} is not in ${token}');
	}

	static function assertThat(value:Bool):Dynamic
		return value ? null : throw "err";
}
#end
