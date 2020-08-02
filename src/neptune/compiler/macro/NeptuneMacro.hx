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

import haxe.macro.Context;
import haxe.macro.Expr;
import neptune.compiler.dom.Scanner;
import neptune.compiler.dom.Parser;
using neptune.compiler.macro.Utils;
using haxe.macro.ExprTools;
using StringTools;

#if macro
class NeptuneMacro
{
  macro static public function fromInterface():Array<Field> 
  {
    var fields = Context.getBuildFields()
      .map(transformFieldKind);

    return fields;
  }
  
  static function transformFieldKind(field :Field) : Field
  {
      return switch field.kind {
        case FFun(f): {
          {
            name: field.name,
            doc: field.doc,
            access: [APublic],
            kind: FFun({
              args: f.args,
              ret: f.ret,
              expr: MetaTransformer.transformMarkup(compileMarkup, f.expr),
              params: f.params
            }),
            pos: field.pos,
            meta: field.meta
          };
        }
        case FVar(t, e):
          {
            name: field.name,
            doc: field.doc,
            access: [APublic],
            kind: FVar(t, MetaTransformer.transformMarkup(compileMarkup, e)),
            pos: field.pos,
            meta: field.meta
          };
        case FProp(get, set, t, e):
          {
            name: field.name,
            doc: field.doc,
            access: [APublic],
            kind: FProp(get, set, t, MetaTransformer.transformMarkup(compileMarkup, e)),
            pos: field.pos,
            meta: field.meta
          };
      }
  }
  
  public static function compileMarkup(e :Expr) : Expr
  {
    var xml = switch e.expr {
      case EConst(c): switch c {
        case CString(s, _): s;
        case _: throw "err";
      }
      case _: throw "err";
    }
    var start = Context.getPosInfos(e.pos).min;
    var filename = Context.getPosInfos(Context.currentPos()).file;
    var result = Parser.parse(new Scanner(filename, xml, start));
    return {
      pos: e.pos,
      expr: EConst(CString(xml))
    };
  }
}
#end