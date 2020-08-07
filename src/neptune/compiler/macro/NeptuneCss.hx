package neptune.compiler.macro;

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

#if macro
import haxe.macro.Expr;
import haxe.ds.Option;
using neptune.compiler.macro.NStringUtils;

class NeptuneCss
{
    public static function handleStyle(fields :Array<Field>) : Void
    {
        switch getStyle(fields) {
            case Some(v):
                // sys.io.File.saveContent("./dist/style.css", v);
            case None:
        }
    }

    private static function getStyle(fields :Array<Field>) : Option<String>
    {
        for(field in fields) {
            if(field.name == "style") {
                fields.remove(field);
                switch field.kind {
                    case FVar(t, e):
                        switch e.expr {
                            case EMeta(s, e): switch e.expr {
                                case EConst(c): switch c {
                                    case CString(s, kind): 
                                        return transformStyle(s);
                                    case _: 
                                        throw "not valid css";
                                }
                                case _: 
                                    throw "not valid css";
                            }
                            case _: 
                                throw "not valid css";
                        }
                    case _: 
                        throw "not valid css";
                }
            }
        }
        return None;
    }

    private static function transformStyle(style :String) : Option<String>
    {
        var str = style.cleanWhitespaceCompletely();

        var reg = ~/<style>(.*)<\/style>/gm;
        var hasMatch = reg.match(str);
        return hasMatch ? Some(reg.matched(1)) : None;
    }
}
#end