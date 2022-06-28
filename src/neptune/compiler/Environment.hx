package neptune.compiler;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Var;
import haxe.macro.Expr.Field;

using Lambda;

enum EnvironmentItem {
	EField(f:Field);
	EVar(v:Var);
}

class Environment {
	public var name(default, null):String;

	public function new():Void {
		this._items = new Map();
	}

	public function addField(field:Field):Field {
		if (this._items.exists(field.name)) {
			throw 'Item already exists: ${field.name}';
		}
		this._items.set(field.name, EField(field));
		return field;
	}

	public function addVar(var_:Var):Var {
		if (this._items.exists(var_.name)) {
			throw 'Item already exists: ${var_.name}';
		}
		this._items.set(var_.name, EVar(var_));
		return var_;
	}

	public function makeChild():Environment {
		var e = new Environment();
		e._parent = this;
		this._children.push(e);
		return e;
	}

	public function getType(expr:Null<Expr>):haxe.macro.Type {
		if (expr == null) {
			throw "getType: invalid expression";
		}
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
				case _:
					trace(expr.expr.getName());
					throw "not implemented";
			}
		}
	}

	private function getEnvironmentItem(name:String):Null<Expr> {
		var item = this._items.get(name);
		if (item != null) {
			return switch item {
				case EField(f): switch f.kind {
						case FVar(t, e): throw "not implemented";
						case FFun(f): throw "not implemented";
						case FProp(get, set, t, e): throw "not implemented";
					}
				case EVar(v): v.expr;
			}
		} else if (this._parent != null) {
			return this._parent.getEnvironmentItem(name);
		}
		return null;
	}

	private var _parent:Null<Environment> = null;
	private var _children:Array<Environment> = [];
	private var _items:Map<String, EnvironmentItem>;
}
#end
