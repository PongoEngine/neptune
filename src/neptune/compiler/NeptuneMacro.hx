package neptune.compiler;

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
#if macro
import neptune.compiler.Environment.EnvRef;
import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

class NeptuneMacro {
	/**
	 * [Description]
	 * @return Array<Field>
	 */
	macro static public function fromInterface():Array<Field> {
		var fields = Context.getBuildFields();
		var ctx = new Environment();
		var fields = fields.map(Transform.transformField.bind({ref: ctx}));
		Environment.ROOT.handleDeps();

		#if debugFields
		for (field in fields) {
			trace(new haxe.macro.Printer().printField(field));
		}
		#end

		#if debugEnv
		if (Environment.ROOT != null) {
			trace(new haxe.macro.Printer().printExpr(Environment.ROOT.makeChildrenTree()));
		}
		#end
		// trace(new haxe.macro.Printer().printExpr(EnvironmentUtil.makeChildrenTree(Environment.ROOT)));
		return fields;
	}
}
#end
