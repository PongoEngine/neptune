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
	 * @param env 
	 * @param graph 
	 * @param expr 
	 * @return Expr
	 */
	 public static function transformExpr(env:EnvRef, expr:Null<Expr>):Expr {
		if (expr == null) {
			return null;
		}
		return switch expr.expr {
			case EConst(_), EDisplayNew(_), EBreak, EContinue:
				expr;
			case EArray(e1, e2):
				{
					expr: EArray(transformExpr(env, e1), transformExpr(env, e2)),
					pos: expr.pos
				};
			case EBinop(op, e1, e2):
				var expr = {
					expr: EBinop(op, transformExpr(env, e1), transformExpr(env, e2)),
					pos: expr.pos
				};
				switch op {
					case OpAssign: env.ref.addExpr(expr);
					case OpAssignOp(op): env.ref.addExpr(expr);
					case _: expr;
				}
			case EField(e, field):
				{
					expr: EField(transformExpr(env, e), field),
					pos: expr.pos
				};
			case EParenthesis(e):
				{
					expr: EParenthesis(transformExpr(env, e)),
					pos: expr.pos
				};
			case EObjectDecl(fields):
				{
					expr: EObjectDecl(fields.map(f -> {
						field: f.field,
						expr: transformExpr(env, f.expr),
						quotes: f.quotes,
					})),
					pos: expr.pos
				};
			case EArrayDecl(values):
				{
					expr: EArrayDecl(values.map(transformExpr.bind(env))),
					pos: expr.pos
				};
			case ECall(e, params):
				{
					expr: ECall(transformExpr(env, e), params.map(transformExpr.bind(env))),
					pos: expr.pos
				};
			case ENew(t, params):
				{
					expr: ENew(t, params.map(transformExpr.bind(env))),
					pos: expr.pos
				};
			case EUnop(op, postFix, e):
				{
					expr: EUnop(op, postFix, transformExpr(env, e)),
					pos: expr.pos
				};
			case EVars(vars):
				env.ref.addExpr({
					expr: EVars(vars.map(transformVar.bind(env))),
					pos: expr.pos
				});
			case EFunction(kind, f):
				{
					expr: EFunction(kind, transformFunction(env, f)),
					pos: expr.pos
				};
			case EBlock(exprs):
				// change the Parser env reference so that it matches transformExpr
				env.ref = env.ref.makeChild();
				{
					expr: EBlock(exprs.map(transformExpr.bind(env))),
					pos: expr.pos
				};
			case EFor(it, expr):
				{
					expr: EFor(transformExpr(env, it), transformExpr(env, expr)),
					pos: expr.pos
				};
			case EIf(econd, eif, eelse):
				{
					expr: EIf(transformExpr(env, econd), transformExpr(env, eif), transformExpr(env, eelse)),
					pos: expr.pos
				};
			case EWhile(econd, e, normalWhile):
				{
					expr: EWhile(transformExpr(env, econd), transformExpr(env, e), normalWhile),
					pos: expr.pos
				};
			case ESwitch(e, cases, edef):
				throw 'Not implemented';
			case ETry(e, catches):
				throw 'Not implemented';
			case EReturn(e):
				{
					expr: EReturn(transformExpr(env, e)),
					pos: expr.pos
				};
			case EUntyped(e):
				{
					expr: EUntyped(transformExpr(env, e)),
					pos: expr.pos
				};
			case EThrow(e):
				{
					expr: EThrow(transformExpr(env, e)),
					pos: expr.pos
				};
			case ECast(e, t):
				{
					expr: ECast(transformExpr(env, e), t),
					pos: expr.pos
				};
			case EDisplay(e, displayKind):
				{
					expr: EDisplay(transformExpr(env, e), displayKind),
					pos: expr.pos
				};
			case ETernary(econd, eif, eelse):
				{
					expr: ETernary(transformExpr(env, econd), transformExpr(env, eif), transformExpr(env, eelse)),
					pos: expr.pos
				};
			case ECheckType(e, t):
				{
					expr: ECheckType(transformExpr(env, e), t),
					pos: expr.pos
				};
			case EMeta(s, e):
				switch s.name {
					case ":markup": transformMarkup(env, e);
					case _: expr;
				};
			case EIs(e, t):
				{
					expr: EIs(transformExpr(env, e), t),
					pos: expr.pos
				};
		}
	}

	/**
	 * [Description]
	 * @param f 
	 * @return Function
	 */
	public static function transformFunction(env:EnvRef, f:Function):Function {
		// for (arg in f.args) {
		// 	env.ref.addArg(arg);
		// }
		return {
			args: f.args,
			ret: f.ret,
			expr: transformExpr(env, f.expr),
			params: f.params,
		};
	}

	/**
	 * [Description]
	 * @param env 
	 * @param field 
	 * @return Field
	 */
	public static function transformField(env:EnvRef, field:Field):Field {
		return {
			name: field.name,
			doc: field.doc,
			access: field.access,
			kind: switch field.kind {
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
						case _: FFun(transformFunction(env, f));
					}
				case FProp(get, set, t, e): throw "not implemented";
			},
			pos: field.pos,
			meta: field.meta,
		};
	}
}
#end
