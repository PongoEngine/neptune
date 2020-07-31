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
import neptune.compiler.macro.Compiler;
import neptune.compiler.macro.Deps;
using neptune.compiler.macro.Utils;
using haxe.macro.ExprTools;
using StringTools;

#if macro
class NeptuneMacro
{
  macro static public function fromInterface():Array<Field> 
  {
    var deps = new Deps();
    var fields = Context.getBuildFields()
      .map(transformFieldKind.bind(deps));

    fields = fields.concat(deps.createConstructorFields());
    fields.push(deps.createConstructor());

    //create setter functions
    fields = fields.concat(deps.createDependentSetters(fields));
    //wrap dependent fields with setters
    fields = deps.transformDependentFields(fields);

    return fields;
  }
  
  static function transformFieldKind(deps :Deps, field :Field) : Field
  {
    return switch field.kind {
      case FFun(f): {
        {
          pos: field.pos,
          name: field.name,
          access: [APublic],
          kind: FFun({
            args: f.args,
            ret: f.ret,
            expr: transformMarkup(deps, f.expr),
            params: f.params
          })
        };
      }
      case _: field;
    }
  }

  static function transformMarkup(deps :Deps, expr :Expr) : Expr
  {
    return switch expr.expr {
      case EMeta(s, e):
        compileMarkup(deps, e);
      case EBlock(exprs):
        {
          pos: Context.currentPos(),
          expr: EBlock(exprs.map(transformMarkup.bind(deps)))
        }
      case EReturn(e):
        {
          pos: Context.currentPos(),
          expr: EReturn(transformMarkup(deps, e))
        }
      case _:
        expr;
    }
  }
  
  public static function compileMarkup(deps :Deps, e :Expr) : Expr
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
    return Compiler.compile(deps, result);
  }
}
#end