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
#if macro
import neptune.compiler.Environment.EnvRef;
import haxe.macro.Type.AbstractType;
import haxe.macro.Type.ClassType;
import neptune.compiler.Token;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;
using neptune.compiler.Scanner.ScannerTools;

class Parser {
	public static function parseNode(env:EnvRef, scanner:Scanner):Null<Expr> {
		return switch scanner.peekToken() {
			case ELEMENT_OPENED:
				parseElementNode(env, scanner);
			case _:
				parseTextNode(env, scanner);
		}
	}

	static function parseNodes(env:EnvRef, scanner:Scanner):Array<Expr> {
		var nodes = [];
		while (scanner.hasNext() && !isClosing(scanner)) {
			nodes.push(parseNode(env, scanner));
		}
		return nodes.filter(n -> n != null);
	}

	static var elementIdentIndex = 0;

	static function addExprText(env:EnvRef, ident_addChild:Expr, child:Expr, isNumber:Bool):Expr {
		var fnName = isNumber ? "createTextFromNumber" : "createText";
		var childText = EnvironmentUtil.makeStaticCall(["neptune", "html", "HtmlElement"], fnName, [child], child.pos);
		var ident_addChild_child_ = EnvironmentUtil.makeECall(ident_addChild, [childText], childText.pos);
		return ident_addChild_child_;
	}

	static function addExprNode(env:EnvRef, ident_addChild:Expr, child:Expr):Expr {
		var ident_addChild_child_ = EnvironmentUtil.makeECall(ident_addChild, [child], child.pos);
		return ident_addChild_child_;
	}

	static var fragmentIdentIndex = 0;

	static function transformVoidExpr(env:EnvRef, child:Expr):Expr {
		return switch child.expr {
			case EBlock(blockExprs): if (blockExprs.length > 0) {
					var copy = blockExprs.slice(0);
					copy[blockExprs.length - 1] = transformVoidExpr(env, copy[blockExprs.length - 1]);
				} else {
					throw "Invalid Void Expr";
				}
			case EFor(it, expr):
				var fragmentID = 'fragment_${fragmentIdentIndex++}';
				var exprs:Array<Expr> = [];
				var newFragment = EnvironmentUtil.makeENew(["neptune", "html"], "HtmlFragment", [], child.pos);
				exprs.push(EnvironmentUtil.makeEVar(EnvironmentUtil.makeVar(fragmentID, newFragment), child.pos));
				var exprIdent = EnvironmentUtil.makeCIdent(fragmentID, child.pos);
				var exprFor = EnvironmentUtil.makeEFor(it, addChild(env, exprIdent, expr), child.pos);
				exprs.push(exprFor);
				exprs.push(exprIdent);
				EnvironmentUtil.makeEBlock(exprs, child.pos);
			case _: throw 'Invalid Void Expr: ${child.expr.getName()}';
		}
	}

	static function addChild(env:EnvRef, exprIdent:Expr, child:Expr):Expr {
		var ident_addChild = EnvironmentUtil.makeEField(exprIdent, "addChild", child.pos);
		var childType = env.ref.getType(child);
		return switch env.ref.getType(child) {
			case TMono(_), TEnum(_), TType(_), TFun(_), TAnonymous(_), TDynamic(_), TLazy(_):
				throw 'invalid child type: ${childType}';
			case TInst(t, params):
				var name = classTypeName(t.get());
				switch name {
					case "js.html.Text":
						addExprNode(env, ident_addChild, child);
					case "String":
						addExprText(env, ident_addChild, child, false);
					case _:
						throw name;
				}
			case TAbstract(t, params):
				var name = abstractTypeName(t.get());
				switch name {
					case "Int", "Float":
						addExprText(env, ident_addChild, child, true);
					case "neptune.html.HtmlElement":
						addExprNode(env, ident_addChild, child);
					case "Void":
						child = transformVoidExpr(env, child);
						addExprNode(env, ident_addChild, child);
					case _:
						throw 'Invalid Abstract: ${name}';
				}
		}
	}

	static function parseElementNode(env:EnvRef, scanner:Scanner):Expr {
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

		var newHtmlElement = EnvironmentUtil.makeENew(["neptune", "html"], "HtmlElement", [EnvironmentUtil.makeCString(tagname, pos)], pos);
		var exprs:Array<Expr> = [];
		exprs.push(EnvironmentUtil.makeEVar(EnvironmentUtil.makeVar(elementID, newHtmlElement), pos));
		var exprIdent = EnvironmentUtil.makeCIdent(elementID, pos);

		// add attributes
		for (attr in attrs) {
			var ident_addAttr = EnvironmentUtil.makeEField(exprIdent, "addAttr", attr.pos);
			var ident_addAttr_attr_ = EnvironmentUtil.makeECall(ident_addAttr, [attr], attr.pos);
			exprs.push(ident_addAttr_attr_);
		}

		// add children
		for (child in children) {
			exprs.push(addChild(env, exprIdent, child));
		}

		exprs.push(exprIdent);
		return EnvironmentUtil.makeEBlock(exprs, pos);
	}

	static function parseTextNode(env:EnvRef, scanner:Scanner):Null<Expr> {
		return switch scanner.peekToken() {
			case Token.CURLY_BRACE_OPENED:
				getHaxeExpr(env, scanner);
			case _:
				{
					var min = scanner.curIndex;
					var text = scanner.consumeWhile((str) -> {
						str != Token.ELEMENT_OPENED
						&& str != Token.CURLY_BRACE_OPENED;
					});

					if (onlySpaces(text)) {
						null;
					} else {
						var max = scanner.curIndex;
						var pos = scanner.makePosition(min, max);
						var textExpr = EnvironmentUtil.makeCString(text, pos);
						EnvironmentUtil.makeStaticCall(["neptune", "html", "HtmlElement"], "createText", [textExpr], textExpr.pos);
					}
				}
		}
	}

	static function getAttributeExprs(env:EnvRef, scanner:Scanner):Array<Expr> {
		var attrs = [];
		while (scanner.hasNext() && scanner.peek() != Token.ELEMENT_CLOSED) {
			scanner.consumeWhile(ScannerTools.isWhitespace);
			attrs.push(getAttributeExpr(env, scanner));
		}
		return attrs;
	}

	static function getAttributeExpr(env:EnvRef, scanner:Scanner):Expr {
		var min = scanner.curIndex;
		var name = getTagname(scanner);
		assertToken(scanner.next(), Token.EQUALS);
		var attr = getExpr(env, scanner);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);
		return EnvironmentUtil.makeENew(["neptune", "html"], "HtmlAttribute", [EnvironmentUtil.makeCString(name, pos), attr], pos);
	}

	static function getExpr(env:EnvRef, scanner:Scanner):Expr {
		return switch scanner.peekToken() {
			case Token.DBL_QUOTE: getStringExpr(env, scanner);
			case Token.CURLY_BRACE_OPENED: getHaxeExpr(env, scanner);
			case _: assertThat(false);
		}
	}

	static function getStringExpr(env:EnvRef, scanner:Scanner):Expr {
		var min = scanner.curIndex;
		assertToken(scanner.next(), Token.DBL_QUOTE);
		var attrValue = scanner.consumeWhile((str) -> {
			return !(str == '"' || str == "}");
		});
		assertToken(scanner.next(), Token.DBL_QUOTE);
		var max = scanner.curIndex;
		var pos = scanner.makePosition(min, max);
		return EnvironmentUtil.makeCString(attrValue, pos);
	}

	/**
	 * [Description]
	 * @param scanner 
	 * @param isAttribute 
	 * @return Expr
	 */
	static function getHaxeExpr(env:EnvRef, scanner:Scanner):Expr {
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

		var expr = Context.parse('{${exprStr}}', pos);
		return Transform.transformExpr(env, expr);
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
	 * [Description]
	 * @param classType 
	 * @return String
	 */
	static function classTypeName(classType:ClassType):String {
		var p = classType.pack.slice(0);
		p.push(classType.name);
		return p.join(".");
	}

	/**
	 * [Description]
	 * @param abstractType 
	 * @return String
	 */
	static function abstractTypeName(abstractType:AbstractType):String {
		var p = abstractType.pack.slice(0);
		p.push(abstractType.name);
		return p.join(".");
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

	public static function onlySpaces(str:String):Bool {
		return str.trim().length == 0;
	}

	static function assertToken(value:String, token:Token):Dynamic {
		return value == token ? null : (throw '${value} is not in ${token}');
	}

	static function assertThat(value:Bool):Dynamic
		return value ? null : throw "err";
}
#end
