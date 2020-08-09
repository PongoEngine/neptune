package neptune.platform.html;

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

class HtmlPlatform
{
    public static function createElement(tagname :String) : Element
    {
        return document.createElement(tagname);
    }

    public static function createText(text :Dynamic) : Text
    {
        return document.createTextNode(text);
    }

    public static function ternary(condition :Bool, left :Node, right :Node) : Node
    {
        return condition ? left : right;
    }

    public static function updateTextNode(node :Text, value :Dynamic) : Text
    {
        node.textContent = value;
        return node;
    }

    public static function updateParent(condition :Bool, left :Node, right :Node) : Void
    {
        if(condition) {
            var parent = right.parentNode;
            parent.replaceChild(left, right);
        }
        else {
            var parent = left.parentNode;
            parent.replaceChild(right, left);
        }
    }

    public static function addChildren(element :Element, children :Array<Node>) : Element
    {
        for(child in children) {
        addChild(element, child);
        }
        return element;
    }

    public static function addAttr(element :Element, name :String, value :Dynamic) : Element
    {
        element.setAttribute(name, value);
        return element;
    }

    public static function onclick(element :Element, value :Dynamic) : Element
    {
        element.onclick = value;
        return element;
    }

    public static function addChild(element :Element, child :Node) : Element
    {
        element.appendChild(child);
        return element;
    }

    public static function removeChild(element :Element, child :Node) : Void
    {
        element.removeChild(child);
    }
}