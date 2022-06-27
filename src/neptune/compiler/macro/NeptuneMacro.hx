package neptune.compiler.macro;

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
import neptune.compiler.dom.Scanner;
import neptune.compiler.dom.Parser;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

class NeptuneMacro {
	/**
	 * [Description]
	 * @return Array<Field>
	 */
	macro static public function fromInterface():Array<Field> {
		var fields = Context.getBuildFields();
		return fields.map(transformField).filter(field -> field != null);
	}

	/**
	 * [Description]
	 * @param v 
	 * @return Var
	 */
	static function transformVar(v:Var):Var {
		return {
			name: v.name,
			type: v.type,
			expr: transformExpr(v.expr),
			isFinal: v.isFinal,
			meta: v.meta,
		}
	}

	/**
	 * [Description]
	 * @param expr 
	 * @return Expr
	 */
	static function transformMarkup(expr:Expr):Expr {
		return switch expr.expr {
			case EConst(c):
				switch c {
					case CString(s, kind):
						var posInfo = Context.getPosInfos(expr.pos);
						var scanner = new Scanner(posInfo, s);
						return Parser.parse(scanner);
					case _: throw 'Invalid Markup';
				}
			case _: throw 'Invalid Markup';
		}
	}

	/**
	 * [Description]
	 * @param expr 
	 * @return Expr
	 */
	public static function transformExpr(?expr:Expr):Expr {
		if (expr == null) {
			return null;
		}
		var def:ExprDef = switch expr.expr {
			case EConst(c): EConst(c);
			case EArray(e1, e2): EArray(transformExpr(e1), transformExpr(e2));
			case EBinop(op, e1, e2): EBinop(op, transformExpr(e1), transformExpr(e2));
			case EField(e, field): EField(transformExpr(e), field);
			case EParenthesis(e): EParenthesis(transformExpr(e));
			case EObjectDecl(fields): EObjectDecl(fields.map(f -> {
					field: f.field,
					expr: transformExpr(f.expr),
					quotes: f.quotes,
				}));
			case EArrayDecl(values): EArrayDecl(values.map(transformExpr));
			case ECall(e, params): ECall(transformExpr(e), params.map(transformExpr));
			case ENew(t, params): ENew(t, params.map(transformExpr));
			case EUnop(op, postFix, e): EUnop(op, postFix, transformExpr(e));
			case EVars(vars): EVars(vars.map(transformVar));
			case EFunction(kind, f): EFunction(kind, transformFunction(f));
			case EBlock(exprs): EBlock(exprs.map(transformExpr));
			case EFor(it, expr): EFor(transformExpr(it), transformExpr(expr));
			case EIf(econd, eif, eelse): EIf(transformExpr(econd), transformExpr(eif), transformExpr(eelse));
			case EWhile(econd, e, normalWhile): EWhile(transformExpr(econd), transformExpr(e), normalWhile);
			case ESwitch(e, cases, edef): throw 'Not implemented';
			case ETry(e, catches): throw 'Not implemented';
			case EReturn(e): EReturn(transformExpr(e));
			case EBreak: EBreak;
			case EContinue: EContinue;
			case EUntyped(e): EUntyped(transformExpr(e));
			case EThrow(e): EThrow(transformExpr(e));
			case ECast(e, t): ECast(transformExpr(e), t);
			case EDisplay(e, displayKind): EDisplay(transformExpr(e), displayKind);
			case EDisplayNew(t): EDisplayNew(t);
			case ETernary(econd, eif, eelse): ETernary(transformExpr(econd), transformExpr(eif), transformExpr(eelse));
			case ECheckType(e, t): ECheckType(transformExpr(e), t);
			case EMeta(s, e):
				switch s.name {
					case ":markup": return transformMarkup(e);
					case _: EMeta(s, e);
				}
			case EIs(e, t): EIs(transformExpr(e), t);
		}
		return {
			pos: expr.pos,
			expr: def,
		}
	}

	/**
	 * [Description]
	 * @param f 
	 * @return Function
	 */
	static function transformFunction(f:Function):Function {
		return {
			args: f.args,
			ret: f.ret,
			expr: transformExpr(f.expr),
			params: f.params,
		};
	}

	/**
	 * [Description]
	 * @param field 
	 * @return Field
	 */
	static function transformField(field:Field):Field {
		var kind:FieldType = switch field.kind {
			case FVar(t, e):
				switch t {
					case TPath(p): throw "not implemented";
					case TFunction(args, ret): throw "not implemented";
					case TAnonymous(fields): throw "not implemented";
					case TParent(t): throw "not implemented";
					case TExtend(p, fields): throw "not implemented";
					case TOptional(t): throw "not implemented";
					case TNamed(n, t): throw "not implemented";
					case TIntersection(tl): throw "not implemented";
				}
			case FFun(f):
				switch field.name {
					case "new": field.kind;
					case _: FFun(transformFunction(f));
				}
			case FProp(get, set, t, e): throw "not implemented";
		}

		return {
			name: field.name,
			doc: field.doc,
			access: field.access,
			kind: kind,
			pos: field.pos,
			meta: field.meta,
		};
	}
}
#end
