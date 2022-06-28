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
import haxe.macro.Expr.Position;
import neptune.compiler.Token;
import haxe.macro.Context;

using neptune.compiler.Scanner.ScannerTools;

class Scanner {
	public var content (default, null):String;
	public var curIndex (get, null):Int;

	/**
	 * [Description]
	 * @param position 
	 * @param content 
	 */
	public function new(position :{min:Int, max:Int, file:String}, content:String):Void {
		this._position = position;
		this.content = content;
		this._curIndex = 0;
	}

	/**
	 * [Description]
	 * @return Bool
	 */
	public function hasNext():Bool {
		return this._curIndex < this.content.length;
	}

	/**
	 * [Description]
	 * @return String
	 */
	public function next():String {
		return this.content.charAt(this._curIndex++);
	}

	/**
	 * [Description]
	 * @return String
	 */
	public function peek():String {
		return this.content.charAt(this._curIndex);
	}

	/**
	 * [Description]
	 * @return String
	 */
	public function peekDouble():String {
		return this.content.charAt(this._curIndex + 1);
	}

	/**
	 * [Description]
	 * @param fn 
	 * @return String
	 */
	public function consumeWhile(fn:String->Bool):String {
		var str = "";
		while (this.hasNext() && fn(this.peek())) {
			str += this.next();
		}
		return str;
	}

	/**
	 * [Description]
	 * @return Token
	 */
	public inline function nextToken():Token {
		return this.next();
	}

	/**
	 * [Description]
	 * @return Token
	 */
	public inline function peekToken():Token {
		return this.peek();
	}

	/**
	 * [Description]
	 * @return Token
	 */
	public inline function peekDoubleToken():Token {
		return this.peekDoubleToken();
	}

	/**
	 * [Description]
	 * @param fn 
	 * @return Token
	 */
	public inline function consumeWhileToken(fn:String->Bool):Token {
		return this.consumeWhileToken(fn);
	}

	/**
	 * [Description]
	 * @param min 
	 * @param max 
	 * @return Position
	 */
	public function makePosition(min :Int, max :Int) : Position {
		return Context.makePosition({file: this._position.file, min: min, max: max});
	}

	private function get_curIndex() : Int {
		return this._curIndex + this._position.min;
	}

	private var _position :{min:Int, max:Int, file:String};
	private var _curIndex :Int;
}

class ScannerTools {
	/**
	 * [Description]
	 * @param ch 
	 * @return Bool
	 */
	public static function isWhitespace(ch:String):Bool {
		return ch == SPACE || ch == LINE || ch == TAB;
	}

	/**
	 * [Description]
	 * @param ch 
	 * @return Bool
	 */
	public static function isAlphaNumeric(ch:String):Bool {
		var code = ch.charCodeAt(0);
		if (!(code > 47 && code < 58) && // numeric (0-9)
			!(code > 64 && code < 91) && // upper alpha (A-Z)
			!(code > 96 && code < 123)) { // lower alpha (a-z)
			return false;
		}
		return true;
	};
}
#end