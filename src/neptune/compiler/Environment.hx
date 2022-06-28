package neptune.compiler;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Var;
import haxe.macro.Expr.Field;
import neptune.compiler.MakeExpr.*;

using Lambda;

enum EnvironmentItem {
	EField(f:Field);
	EVar(v:Var);
}

typedef EnvRef = {
	ref :Environment
}

class Environment {
	private static var ENV_NUM = 0;
	public static var ROOT :Environment = null;
	public var name(default, null):String;

	public function new():Void {
		this._items = new Map();
		this.name = 'Env_${ENV_NUM++}';
		if(Environment.ROOT == null) {
			Environment.ROOT = this;
		}
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

	/**
	 * Used for debugging
	 * @return Expr
	 */
	public function makeVarBlock() : Expr {
		var curPos = Context.currentPos();
		var exprs :Array<Expr> = [];
		for(item in this._items) {
			switch item {
				case EField(field): switch field.kind {
					case FVar(t, e): throw "not implemented";
					case FFun(f): exprs.push(makeCIdent(field.name, f.expr.pos));
					case FProp(get, set, t, e): throw "not implemented";
				}
				case EVar(v): exprs.push(makeCIdent(v.name, v.expr.pos));
			}
		}
		return makeEBlock(exprs, Context.currentPos());
	}

	/**
	 * Used for debugging
	 * @return Expr
	 */
	public function makeChildrenTree() : Expr {
		var childrenBlock = [];
		for(child in this._children) {
			childrenBlock.push(child.makeChildrenTree());
		}
		var childrenBlock = makeEBlock(childrenBlock, Context.currentPos());
		var content = makeVar(this.name + "_content", this.makeVarBlock());
		var children = makeVar(this.name + "_children", childrenBlock);
		return makeEVars([content, children], Context.currentPos());
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
		return throw '${name} not found!';
	}

	private var _parent:Null<Environment> = null;
	private var _children:Array<Environment> = [];
	private var _items:Map<String, EnvironmentItem>;
}
#end
