package neptune.lib;

/*
 * Copyright (c) 2020 Jeremy Meltingtallow
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

class Runtime
{
    public static inline function createElement(tagname :String) : Element
    {
      return document.createElement(tagname);
    }

    public static inline function createText(text :Dynamic) : Text
    {
      return document.createTextNode(text);
    }

    public static function updateDependencies(cbs :Array<Void -> Void>) : Void
    {
      for(cb in cbs) {
        cb();
      }
    }

    public static inline function updateTextNode(text :js.html.Text, content :Dynamic) : Void -> Void
    {
      return () -> {
        text.textContent = content;
      }
    }

    public static inline function addTextNode(text :js.html.Text, a :Float, b :Float) : Void -> Void
    {
      return () -> {
        text.textContent = cast (a + b);
      }
    }

    public static inline function addAttr(element :Element, attrName :String, attrValue :Dynamic) : Void
    {
      element.setAttribute(attrName, attrValue);
    }

    public static inline function removeAttr(element :Element, attrName :String) : Void
    {
      element.removeAttribute(attrName);
    }

    public static inline function addAttrEvent(element :Element, attrName :String, attrValue :Dynamic) : Void
    {
      element.addEventListener("click", attrValue);
    }

    public static inline function removeAttrEvent(element :Element, attrName :String, attrValue :Dynamic) : Void
    {
      element.removeEventListener(attrName, attrValue);
    }

    public inline static function addChild(element :Element, child :Node) : Void
    {
      element.appendChild(child);
    }

    public inline static function removeChild(element :Element, child :Node) : Void
    {
      element.removeChild(child);
    }
}