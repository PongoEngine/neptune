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
import neptune.compiler.macro.scope.Scope;
import neptune.compiler.macro.scope.ScopeModule;
import neptune.compiler.macro.compile.Compile;
import haxe.macro.Printer;
import haxe.macro.Context;
import haxe.macro.Expr;
using neptune.compiler.macro.ExprUtils;

class NeptuneMacro
{
    macro static public function fromInterface():Array<Field> 
    {
        var fields = Context.getBuildFields();
        var scope = new ScopeModule(fields);
        var scopes :Array<Scope> = [scope];
        for(field in fields) {
            handleField(field, scope, scopes);
        }

        for(scope in scopes) {
            scope.pushAssignments();
        }

        for(scope in scopes) {
            scope.updateBlock();
        }

        #if debugFields
        for(field in fields) {
            var printer = new Printer("  ");
            var fieldStr = "\n" + printer.printField(field) + "\n\n";
            trace(fieldStr);
        }
        #end
        
        return fields;
    }

    private static function handleField(field :Field, scope :Scope, scopes :Array<Scope>) : Void
    {
        switch field.kind {
            case FVar(t, e):
                handleExpr(e, scope, scopes);
            case FFun(f):
                handleFunction(f, scope, scopes);
            case FProp(get, set, t, e):
                handleExpr(e, scope, scopes);
        }
    }

    private static function handleExpr(expr :Expr, scope :Scope, scopes :Array<Scope>) : Void
    {
        if(expr == null) return;
        switch expr.expr {
            case EArray(e1, e2):
                handleExpr(e1, scope, scopes);
                handleExpr(e2, scope, scopes);

            case EArrayDecl(values):
                for(value in values)
                    handleExpr(value, scope, scopes);

            case EBinop(op, e1, e2):
                handleExpr(e1, scope, scopes);
                handleExpr(e2, scope, scopes);
                switch op {
                    case OpAssign | OpAssignOp(_):
                        scope.transformAssignment(expr);
                    case _:
                }

            case EBlock(exprs):
                var child = scope.createChild(exprs);
                scopes.push(child);
                for(expr in exprs)
                    handleExpr(expr, child, scopes);

            case EBreak:

            case ECall(e, params):
                for(param in params)
                    handleExpr(param, scope, scopes);

            case ECast(e, t):
                handleExpr(e, scope, scopes);

            case ECheckType(e, t):

            case EConst(c):

            case EContinue:

            case EDisplay(e, displayKind):

            case EDisplayNew(t):

            case EField(e, field):
            
            case EFor(it, expr):
                handleExpr(expr, scope, scopes);

            case EFunction(kind, f):
                handleFunction(f, scope, scopes);

            case EIf(econd, eif, eelse):
                handleExpr(econd, scope, scopes);
                handleExpr(eif, scope, scopes);
                handleExpr(eelse, scope, scopes);

            case EMeta(s, e):
                var dom = Compile.compileMeta(e);
                var exprDef = Compile.handleTree(scope, dom).expr;
                expr.expr = exprDef;

            case ENew(t, params):
                for(param in params) {
                    handleExpr(param, scope, scopes);
                }
                
            case EObjectDecl(fields):
                for(field in fields) {
                    handleExpr(field.expr, scope, scopes);
                }

            case EParenthesis(e):
                handleExpr(e, scope, scopes);

            case EReturn(e):
                handleExpr(e, scope, scopes);

            case ESwitch(e, cases, edef):
                handleExpr(e, scope, scopes);
                for(case_ in cases) {
                    handleExpr(case_.expr, scope, scopes);
                    handleExpr(case_.guard, scope, scopes);
                    for(value in case_.values) {
                        handleExpr(value, scope, scopes);
                    }
                }
                handleExpr(edef, scope, scopes);

            case ETernary(econd, eif, eelse):
                handleExpr(econd, scope, scopes);    
                handleExpr(eif, scope, scopes);    
                handleExpr(eelse, scope, scopes);    

            case EThrow(e):
                handleExpr(e, scope, scopes);

            case ETry(e, catches):
                handleExpr(e, scope, scopes);
                for(catch_ in catches) {
                    handleExpr(catch_.expr, scope, scopes);
                }

            case EUnop(op, postFix, e):
                handleExpr(e, scope, scopes); 
                switch op {
                    case OpIncrement | OpDecrement:
                        scope.transformAssignment(expr);
                    case _:
                }

            case EWhile(econd, e, normalWhile):
                handleExpr(econd, scope, scopes);
                handleExpr(e, scope, scopes);

            case EVars(vars):
                for(var_ in vars) {
                    scope.saveVar(var_);
                    handleExpr(var_.expr, scope, scopes);
                }

            case EUntyped(e):
                handleExpr(e, scope, scopes);
        }
    }

    private static function handleFunction(function_ :Function, scope :Scope, scopes :Array<Scope>) : Void
    {
        for(arg in function_.args) {
            handleFunctionArg(arg, scope, scopes);
        }
        handleExpr(function_.expr, scope, scopes);
    }

    private static function handleFunctionArg(arg :FunctionArg, scope :Scope, scopes :Array<Scope>) : Void
    {
        handleExpr(arg.value, scope, scopes);
    }
}

#end