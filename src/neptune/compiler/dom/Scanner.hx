package neptune.compiler.dom;

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

import neptune.compiler.dom.Token;
using neptune.compiler.dom.Scanner.ScannerTools;
 
class Scanner
{
    public var filename :String;
    public var content :String;
    public var startingIndex :Int;
    public var curIndex :Int;

    public function new(filename :String, content :String, startingIndex :Int) : Void
    {
        this.filename = filename;
        this.content = content;
        this.startingIndex = startingIndex;
        this.curIndex = 0;
    }

    public function hasNext() : Bool
    {
        return this.curIndex < this.content.length;
    }

    public function next() : String
    {
        return this.content.charAt(this.curIndex++);
    }

    public function peek() : String
    {
        return this.content.charAt(this.curIndex);
    }

    public function peekDouble() : String
    {
        return this.content.charAt(this.curIndex + 1);
    }

    public function consumeWhile(fn :String -> Bool) : String
    {
        var str = "";
        while(fn(this.peek())) {
            str += this.next();
        }
        return str;
    }
}

class ScannerTools
{
    public static function isWhitespace(ch :String) : Bool
    {
        return ch == SPACE || ch == LINE || ch == TAB;
    }

    public static function isAlphaNumeric(ch :String) : Bool 
    {
        var code = ch.charCodeAt(0);
        if (!(code > 47 && code < 58) && // numeric (0-9)
            !(code > 64 && code < 91) && // upper alpha (A-Z)
            !(code > 96 && code < 123)) { // lower alpha (a-z)
            return false;
        }
        return true;
      };
}