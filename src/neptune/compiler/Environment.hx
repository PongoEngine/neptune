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
import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;

using Lambda;

// enum EnvironmentItem {
// 	EField(f:Field);
// 	EVar(name:String, e:Expr);
// 	EFunc(name:String, e:Expr);
// 	EArg(arg:FunctionArg);
// }

typedef EnvRef = {
	ref:Environment
}

class Environment {
	private static var ENV_NUM = 0;
	public static var ROOT:Environment = null;

	public var name(default, null):String;

	public function new():Void {
		this._items = [];
		this.name = 'Env_${ENV_NUM++}';
		if (Environment.ROOT == null) {
			Environment.ROOT = this;
		}
	}

	public function addExpr(expr:Expr):Expr {
		this._items.push(expr);
		return expr;
	}

	public function makeChild():Environment {
		var e = new Environment();
		e._parent = this;
		this._children.push(e);
		return e;
	}

	public function handleDeps():Void {
		var items = this._items;
		for (c in this._children) {
			c.handleDeps();
		}
		var p = new Printer();
		for (item in this._items) {
			trace(p.printExpr(item));
		}
	}

	public function getType(expr:Expr):haxe.macro.Type {
		try {
			return Context.typeof(expr);
		} catch (_) {
			return switch expr.expr {
				case EConst(c):
					switch c {
						case CIdent(s): getType(getEnvironmentItem(s));
						case _: throw "not implemented";
					}
				case EBlock(exprs): switch exprs.length {
						case 0: throw "block cannot be empty!";
						case _:
							var expr = exprs[exprs.length - 1];
							getType(expr);
					}
				case EArray(e1, e2):
					getType(e1);
				case EArrayDecl(values): {
						var types = values.map(getType);
						var first = types[0];
						var matches = true;
						for (type in types) {
							matches = Context.unify(first, type);
							if (!matches) {
								throw "Array must not be dynamic";
							}
						}
						first;
					}
				case EBinop(op, e1, e2):
					var type1 = getType(e1);
					var type2 = getType(e2);
					if (Context.unify(type1, type2)) {
						type1;
					} else {
						throw "not implemented";
					}
				case EReturn(e):
					getType(e);
				case ECall(e, params):
					getType(e);
				case EFunction(_, f):
					getType(f.expr);
				case _:
					trace(expr.expr.getName());
					throw "not implemented";
			}
		}
	}

	private function getEnvironmentItem(name:String):Null<Expr> {
		// trace('Looking for ${name} in ${this.name}');
		// trace(new haxe.macro.Printer().printExpr(this.makeChildrenTree()));

		var item = this.getItem(name);
		if (item != null) {
			return item;
		} else if (this._parent != null) {
			return this._parent.getEnvironmentItem(name);
		}
		return throw '${name} not found!';
	}

	private function getItem(name:String):Null<Expr> {
		for (item in this._items) {
			switch item.expr {
				case EVars(vars):
					{
						for (var_ in vars) {
							if (name == var_.name) {
								return var_.expr;
							}
						}
					}
				case _:
			}
		}
		return null;
	}

	private function itemExists(name:String):Bool {
		return this.getItem(name) != null;
	}

	@:allow(neptune.compiler.EnvironmentUtil) private var _parent:Null<Environment> = null;
	@:allow(neptune.compiler.EnvironmentUtil) private var _children:Array<Environment> = [];
	@:allow(neptune.compiler.EnvironmentUtil) private var _items:Array<Expr>;
}
#end
