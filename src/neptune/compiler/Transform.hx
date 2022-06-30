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
import neptune.compiler.Scanner;
import neptune.compiler.Parser;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

class Transform {
	/**
	 * [Description]
	 * @param v 
	 * @return Var
	 */
	static function transformVar(env:EnvRef, v:Var):Var {
		return {
			name: v.name,
			type: v.type,
			expr: transformExpr(env, v.expr),
			isFinal: v.isFinal,
			meta: v.meta,
		};
	}

	/**
	 * [Description]
	 * @param expr 
	 * @return Expr
	 */
	static function transformMarkup(env:EnvRef, expr:Expr):Expr {
		return switch expr.expr {
			case EConst(c):
				switch c {
					case CString(s, kind):
						var posInfo = Context.getPosInfos(expr.pos);
						var scanner = new Scanner(posInfo, s);
						return Parser.parseNode(env, scanner);
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
	public static function transformExpr(env:EnvRef, expr:Null<Expr>):Expr {
		return env.ref.addExpr(transformExpr_(env, expr));
	}

	
	private static function transformExpr_(env:EnvRef, expr:Null<Expr>):Expr {
		if (expr == null) {
			return null;
		}
		var def:ExprDef = switch expr.expr {
			case EConst(_), EDisplayNew(_), EBreak, EContinue: expr.expr;
			case EArray(e1, e2): EArray(transformExpr(env, e1), transformExpr(env, e2));
			case EBinop(op, e1, e2): EBinop(op, transformExpr(env, e1), transformExpr(env, e2));
			case EField(e, field): EField(transformExpr(env, e), field);
			case EParenthesis(e): EParenthesis(transformExpr(env, e));
			case EObjectDecl(fields): EObjectDecl(fields.map(f -> {
					field: f.field,
					expr: transformExpr(env, f.expr),
					quotes: f.quotes,
				}));
			case EArrayDecl(values): EArrayDecl(values.map(transformExpr.bind(env)));
			case ECall(e, params):
				ECall(transformExpr(env, e), params.map(transformExpr.bind(env)));
			case ENew(t, params): ENew(t, params.map(transformExpr.bind(env)));
			case EUnop(op, postFix, e): EUnop(op, postFix, transformExpr(env, e));
			case EVars(vars): EVars(vars.map(transformVar.bind(env)));
			case EFunction(kind, f):
				for (arg in f.args) {
					env.ref.addArg(arg);
				}
				EFunction(kind, transformFunction(env, f));
			case EBlock(exprs):
				// change the Parser env reference so that it matches transformExpr
				env.ref = env.ref.makeChild();
				EBlock(exprs.map(transformExpr.bind(env)));
			case EFor(it, expr): EFor(transformExpr(env, it), transformExpr(env, expr));
			case EIf(econd, eif, eelse): EIf(transformExpr(env, econd), transformExpr(env, eif), transformExpr(env, eelse));
			case EWhile(econd, e, normalWhile): EWhile(transformExpr(env, econd), transformExpr(env, e), normalWhile);
			case ESwitch(e, cases, edef): throw 'Not implemented';
			case ETry(e, catches): throw 'Not implemented';
			case EReturn(e): EReturn(transformExpr(env, e));
			case EUntyped(e): EUntyped(transformExpr(env, e));
			case EThrow(e): EThrow(transformExpr(env, e));
			case ECast(e, t): ECast(transformExpr(env, e), t);
			case EDisplay(e, displayKind): EDisplay(transformExpr(env, e), displayKind);
			case ETernary(econd, eif, eelse): ETernary(transformExpr(env, econd), transformExpr(env, eif), transformExpr(env, eelse));
			case ECheckType(e, t): ECheckType(transformExpr(env, e), t);
			case EMeta(s, e):
				switch s.name {
					case ":markup": return env.ref.addMarkup(transformMarkup(env, e));
					case _: expr.expr;
				}
			case EIs(e, t): EIs(transformExpr(env, e), t);
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
	public static function transformFunction(env:EnvRef, f:Function):Function {
		for (arg in f.args) {
			env.ref.addArg(arg);
		}
		return {
			args: f.args,
			ret: f.ret,
			expr: transformExpr(env, f.expr),
			params: f.params,
		};
	}
}
#end
