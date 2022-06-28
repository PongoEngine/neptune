package neptune.compiler;

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
import haxe.macro.Printer;
import haxe.macro.Type.AbstractType;
import haxe.macro.Type.ClassType;
#if macro
import neptune.compiler.NeptuneMacro;
import neptune.compiler.Token;
import haxe.macro.Context;
import haxe.macro.Expr;
import neptune.compiler.MakeExpr.*;

using neptune.compiler.Scanner.ScannerTools;

class Parser {
	public static function parse(env:Environment, scanner:Scanner):Expr {
		var nodes = parseNodes(env, scanner);
		assertThat(nodes.length == 1);
		return nodes[0];
	}

	static function parseNode(env:Environment, scanner:Scanner):Expr {
		return switch scanner.peekToken() {
			case ELEMENT_OPENED:
				parseElementNode(env, scanner);
			case _:
				parseTextNode(env, scanner);
		}
	}

	static function parseNodes(env:Environment, scanner:Scanner):Array<Expr> {
		var nodes = [];
		while (scanner.hasNext() && !isClosing(scanner)) {
			nodes.push(parseNode(env, scanner));
		}
		return nodes;
	}

	static var elementIdentIndex = 0;

	static function classTypeName(classType:ClassType) {
		var p = classType.pack.slice(0);
		p.push(classType.name);
		return p.join(".");
	}

	static function abstractTypeName(abstractType:AbstractType) {
		var p = abstractType.pack.slice(0);
		p.push(abstractType.name);
		return p.join(".");
	}

	static function addExprText(ident_addChild:Expr, child:Expr, exprs:Array<Expr>, isNumber:Bool):Void {
		var fnName = isNumber ? "createTextFromNumber" : "createText";
		var childText = makeECall(makeCIdent(fnName, child.pos), [child], child.pos);
		var ident_addChild_child_ = makeECall(ident_addChild, [childText], childText.pos);
		exprs.push(ident_addChild_child_);
	}

	static function addExprNode(ident_addChild:Expr, child:Expr, exprs:Array<Expr>):Void {
		var ident_addChild_child_ = makeECall(ident_addChild, [child], child.pos);
		exprs.push(ident_addChild_child_);
	}

	static function parseElementNode(env:Environment, scanner:Scanner):Expr {
		// create element
		var elementID = 'element_${elementIdentIndex++}';
		var min = scanner.curIndex;
		assertToken(scanner.next(), Token.ELEMENT_OPENED);
		scanner.consumeWhile(ScannerTools.isWhitespace);
		var tagname = getTagname(scanner);
		var attrs = getAttributeExprs(env, scanner);
		assertToken(scanner.next(), Token.ELEMENT_CLOSED);
		var children = parseNodes(env, scanner);
		assertToken(scanner.next(), Token.ELEMENT_OPENED);
		assertToken(scanner.next(), Token.FORWARD_SLASH);
		assertThat(getTagname(scanner) == tagname);
		assertToken(scanner.next(), Token.ELEMENT_CLOSED);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);

		var newHtmlElement = makeENew(["neptune", "html"], "HtmlElement", [makeCString(tagname, pos)], pos);
		var exprs:Array<Expr> = [];
		exprs.push(makeEVars([makeVar(env, elementID, newHtmlElement)], pos));
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
			switch env.getType(child) {
				case TMono(_), TEnum(_), TType(_), TFun(_), TAnonymous(_), TDynamic(_), TLazy(_):
					throw "invalid child";
				case TInst(t, params):
					var name = classTypeName(t.get());
					switch name {
						case "js.html.Text":
							addExprNode(ident_addChild, child, exprs);
						case "String":
							addExprText(ident_addChild, child, exprs, false);
						case _:
							throw name;
					}
				case TAbstract(t, params):
					var name = abstractTypeName(t.get());
					switch name {
						case "Int", "Float":
							addExprText(ident_addChild, child, exprs, true);
						case "neptune.html.HtmlElement":
							addExprNode(ident_addChild, child, exprs);
						case _:
							throw name;
					}
			}
		}

		exprs.push(exprIdent);
		return makeEBlock(exprs, pos);
	}

	static function parseTextNode(env:Environment, scanner:Scanner):Expr {
		return switch scanner.peekToken() {
			case Token.CURLY_BRACE_OPENED:
				getHaxeExpr(env, scanner, false);
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

	static function getAttributeExprs(env:Environment, scanner:Scanner):Array<Expr> {
		var attrs = [];
		while (scanner.hasNext() && scanner.peek() != Token.ELEMENT_CLOSED) {
			scanner.consumeWhile(ScannerTools.isWhitespace);
			attrs.push(getAttributeExpr(env, scanner));
		}
		return attrs;
	}

	static function getAttributeExpr(env:Environment, scanner:Scanner):Expr {
		var min = scanner.curIndex;
		var name = getTagname(scanner);
		assertToken(scanner.next(), Token.EQUALS);
		var attr = getExpr(env, scanner);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);
		return makeENew(["neptune", "html"], "HtmlAttribute", [makeCString(name, pos), attr], pos);
	}

	static function getExpr(env:Environment, scanner:Scanner):Expr {
		return switch scanner.peekToken() {
			case Token.DBL_QUOTE: getStringExpr(scanner);
			case Token.CURLY_BRACE_OPENED: getHaxeExpr(env, scanner, true);
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
	static function getHaxeExpr(env:Environment, scanner:Scanner, isAttribute:Bool):Expr {
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
			return NeptuneMacro.transformExpr(env, expr);
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
