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
import neptune.compiler.Environment;
import haxe.macro.Expr;

using Lambda;

class MakeExpr {
	public static function makeStaticCall(fields:Array<String>, fnName:String, params:Array<Expr>, pos:Position):Expr {
		if (fields.length > 0) {
			var root = makeCIdent(fields[0], pos);
			for (field in fields.slice(1)) {
				root = makeEField(root, field, pos);
			}
			root = makeEField(root, fnName, pos);
			return makeECall(root, params, pos);
		} else {
			var root = makeCIdent(fnName, pos);
			return makeECall(root, params, pos);
		}
	}

	public static function makeENew(pack:Array<String>, name:String, params:Array<Expr>, pos:Position):Expr {
		return {
			expr: ENew({
				pack: pack,
				name: name,
				params: null,
				sub: null
			}, params),
			pos: pos
		}
	}

	public static function makeCIdent(ident:String, pos:Position):Expr {
		return {expr: EConst(CIdent(ident)), pos: pos}
	}

	public static function makeCString(str:String, pos:Position):Expr {
		return {expr: EConst(CString(str)), pos: pos}
	}

	public static function makeEField(e:Expr, field:String, pos:Position):Expr {
		return {expr: EField(e, field), pos: pos}
	}

	public static function makeEFor(it:Expr, expr:Expr, pos:Position):Expr {
		return {expr: EFor(it, expr), pos: pos}
	}

	public static function makeECall(e:Expr, params:Array<Expr>, pos:Position):Expr {
		return {
			expr: ECall(e, params),
			pos: pos
		}
	}

	public static function makeEBlock(exprs:Array<Expr>, pos:Position):Expr {
		return {
			expr: EBlock(exprs),
			pos: pos
		}
	}

	public static function makeEVars(vars:Array<Var>, pos:Position):Expr {
		return {
			expr: EVars(vars),
			pos: pos
		}
	}

	public static function makeVar(name:String, expr:Expr, ?env:EnvRef):Var {
		if(env != null) {
			return env.ref.addVar({
				name: name,
				expr: expr
			});
		}
		else {
			return {
				name: name,
				expr: expr
			};
		}
		
	}
}
#end
