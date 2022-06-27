package neptune.html;

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
import js.Browser.document;
import js.html.Element;
import js.html.Text;
import js.html.Node;

abstract HtmlElement(Element) from Element to Element {
	public inline function new(tag:String):Void {
		this = HtmlElement.createElement(tag);
	}

	public static inline function createElement(tagname:String):Element {
		return document.createElement(tagname);
	}

	public static inline function createText(text:String):Text {
		return document.createTextNode(text);
	}

	public inline function addAttr(attr:HtmlAttribute):HtmlElement {
		if (attr.name() == "@click") {
			this.addEventListener('click', attr.value());
		} else {
			this.setAttribute(attr.name(), attr.value());
		}
		return this;
	}

	private inline function addEventListener(attr:HtmlAttribute):HtmlElement {
		this.setAttribute(attr.name(), attr.value());
		return this;
	}

	public function addChild(child:Dynamic):HtmlElement {
		if (child != null) {
			var childType = js.Lib.typeof(child);
			switch childType {
				case "symbol", "function", "undefined", "bigint":
					js.Syntax.code("console.warn({0})", 'Invalid child type: ${childType}');
				case "object":
					switch HtmlElement.getType(child) {
						case 'Node': this.appendChild(child);
						case _: js.Syntax.code("console.warn({0})", 'Invalid child type: ${childType}');
					}
				case "boolean", "number", "string":
					var text = js.Syntax.code("{0}.toString()", child);
					this.appendChild(createText(text));
			}
		}
		return this;
	}

	private static function getType(child:Dynamic):String {
		var proto = js.Syntax.code("Object.getPrototypeOf({0})", child);
		if (proto != null && proto.constructor.name != 'EventTarget') {
			return getType(proto);
		} else {
			return child.constructor.name;
		}
	}
}
