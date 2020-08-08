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
import haxe.macro.Context;
import haxe.macro.Expr;

class NeptuneMacro
{
    macro static public function fromInterface():Array<Field> 
    {
        var fields = Context.getBuildFields();
        for(field in fields) {
            handleField(field);
        }
        
        return fields;
    }

    private static function handleField(field :Field) : Void
    {
        switch field.kind {
            case FVar(t, e):
                handleExpr(e);
            case FFun(f):
                handleFunction(f);
            case FProp(get, set, t, e):
                handleExpr(e);
        }
    }

    private static function handleExpr(expr :Expr) : Void
    {
        if(expr == null) return;
        switch expr.expr {
            case EArray(e1, e2):
                handleExpr(e1);
                handleExpr(e2);

            case EArrayDecl(values):
                for(value in values)
                    handleExpr(value);

            case EBinop(op, e1, e2):
                handleExpr(e1);
                handleExpr(e2);

            case EBlock(exprs):
                for(expr in exprs)
                    handleExpr(expr);

            case EBreak:

            case ECall(e, params):
                for(param in params)
                    handleExpr(param);

            case ECast(e, t):
                handleExpr(e);

            case ECheckType(e, t):

            case EConst(c):

            case EContinue:

            case EDisplay(e, displayKind):

            case EDisplayNew(t):

            case EField(e, field):
            
            case EFor(it, expr):
                handleExpr(expr);

            case EFunction(kind, f):
                handleFunction(f);

            case EIf(econd, eif, eelse):
                handleExpr(econd);
                handleExpr(eif);
                handleExpr(eelse);

            case EMeta(s, e):
                var domTree = CompileString.run(e);
                expr.expr = e.expr;

            case ENew(t, params):
                for(param in params) {
                    handleExpr(param);
                }
                
            case EObjectDecl(fields):
                for(field in fields) {
                    handleExpr(field.expr);
                }

            case EParenthesis(e):
                handleExpr(e);

            case EReturn(e):
                handleExpr(e);

            case ESwitch(e, cases, edef):
                handleExpr(e);
                for(case_ in cases) {
                    handleExpr(case_.expr);
                    handleExpr(case_.guard);
                    for(value in case_.values) {
                        handleExpr(value);
                    }
                }
                handleExpr(edef);

            case ETernary(econd, eif, eelse):
                handleExpr(econd);    
                handleExpr(eif);    
                handleExpr(eelse);    

            case EThrow(e):
                handleExpr(e);

            case ETry(e, catches):
                handleExpr(e);
                for(catch_ in catches) {
                    handleExpr(catch_.expr);
                }

            case EUnop(op, postFix, e):
                handleExpr(e);   

            case EWhile(econd, e, normalWhile):
                handleExpr(econd);
                handleExpr(e);

            case EVars(vars):
                for(var_ in vars) {
                    handleExpr(var_.expr);
                }

            case EUntyped(e):
                handleExpr(e);
        }
    }

    private static function handleFunction(function_ :Function) : Void
    {
        for(arg in function_.args) {
            handleFunctionArg(arg);
        }
        handleExpr(function_.expr);
    }

    private static function handleFunctionArg(arg :FunctionArg) : Void
    {
        handleExpr(arg.value);
    }
}

#end