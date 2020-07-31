package neptune.compiler;

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
import neptune.compiler.Compiler;
import neptune.compiler.Compiler.NewFields;
using neptune.compiler.Utils;
using haxe.macro.ExprTools;
using StringTools;

#if macro
class NeptuneMacro
{
  macro static public function fromInterface():Array<Field> 
  {
    var fields = Context.getBuildFields();
    var fNames = new Map<String, NewFields>();
    var results = fields.map(mapFunc.bind(fNames));

    for(fName in fNames.keyValueIterator()) {
      for(tl in fName.value.topLevel) {
        results.push({
          pos: Context.currentPos(),
          name: tl.name,
          access: [Access.APublic],
          kind: FVar(macro:Dynamic, null)
        });
      }
    }

    var ft = appendConstructor(fNames);
    var field :Field = {
      name: "new",
      kind: ft,
      access: [APublic],
      pos: Context.currentPos()
    }
    results.push(field);
    
    for(nField in addSetters(fNames, results)) {
      results.push(nField);
    }

    return results;
  }

  static function appendConstructor(fNames :Map<String, NewFields>) : FieldType
  {
    var nExprs = [];
    for(fName in fNames.keyValueIterator()) {
      for(tl in fName.value.topLevel) {
        nExprs.push(Binop.OpAssign.createBinop(tl.name.createExprIdent(), tl.expr));
      }
    }
    return FFun({
      args: [],
      ret: null,
      expr: nExprs.createBlock(),
      params: null
    });
  }

  static function addSetters(fnames :Map<String, NewFields>, results:Array<Field>) : Array<Field>
  {
    var newFields :Array<Field> = [];

    for(keyVal in fnames.keyValueIterator()) {
      var item = keyVal.key;
      for(result in results) {
        if(result.name == item) {
          result.kind = switch result.kind {
            case FVar(t, e): {
              newFields.push(createSetter(result, keyVal.value.setterFns, e.pos));
              FProp("default", "set", t, e);
            }
            case FProp(get, set, t, e):
              throw "Not implemented yet";
            case FFun(f):
              throw "Not implemented yet";
          }
        }
      }
    }

    return newFields;
  }

  static function createSetter(field :Field, exprs :Array<Expr>, position :Position) : Field
  {
    return {
      pos: Context.currentPos(),
      name: 'set_${field.name}',
      access: [APublic],
      kind: FFun({
        args: [{name:"val", type: null}],
        ret: null,
        expr: {
          pos: position,
          expr: EBlock([
            OpAssign.createBinop(field.name.createExprIdent(), "val".createExprIdent()),
            updateIdent(field, exprs),
            Utils.createReturn("val".createExprIdent())
          ])
        }
      })
    };
  }

  //call updateIndent function
  static function updateIdent(field :Field, exprs :Array<Expr>) : Expr
  {
    var arraCbs :Expr = {pos:Context.currentPos(), expr: EArrayDecl(exprs)};
    return [field.name.createExprIdent(), arraCbs]
      .createCall("updateIdent");
  }
  
  static function mapFunc(fnames :Map<String, NewFields>, field :Field) : Field
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
            expr: fieldMeta(fnames, f.expr),
            params: f.params
          })
        };
      }
      case _: field;
    }
  }

  static function fieldMeta(fnames :Map<String, NewFields>, expr :Expr) : Expr
  {
    return switch expr.expr {
      case EMeta(s, e):
        transformString(fnames, e);
      case EBlock(exprs):
        {
          pos: Context.currentPos(),
          expr: EBlock(exprs.map(fieldMeta.bind(fnames)))
        }
      case EReturn(e):
        {
          pos: Context.currentPos(),
          expr: EReturn(fieldMeta(fnames, e))
        }
      case _:
        expr;
    }
  }
  
  static function transformString(fnames :Map<String, NewFields>, e :Expr) : Expr
  {
    var xml = switch e.expr {
      case EConst(c): switch c {
        case CString(s, _): s;
        case _: "";
      }
      case _: "";
    }
    var start = Context.getPosInfos(e.pos).min;
    var filename = Context.getPosInfos(Context.currentPos()).file;
    var result = Parser.parse(new Scanner(filename, xml, start));
    return Compiler.compile(fnames, null, result);
  }
}
#end