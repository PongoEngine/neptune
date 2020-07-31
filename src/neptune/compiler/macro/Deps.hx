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

import haxe.macro.Expr;
using neptune.compiler.Utils;

class Deps
{
    public function new() : Void
    {
        _deps = new Map<String, Dep>();
    }

    public function getDep(name :String) : Dep
    {
        if(!_deps.exists(name)) {
            _deps.set(name, new Dep());
        }
        return _deps.get(name);
    }

    public inline function keyValueIterator() : KeyValueIterator<String, Dep>
    {
        return _deps.keyValueIterator();
    }

    private var _deps :Map<String, Dep>;
}

class Dep
{
    public var topLevel :Array<{name :String, expr :Expr}>;
    public var setterFns :Array<Expr>;

    public function new() : Void
    {
        this.topLevel = [];
        this.setterFns = [];
    }
}