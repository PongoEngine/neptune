// Generated by Haxe 4.2.1+bf9ff69
(function ($global) { "use strict";
var Expressions = function() {
};
Expressions.prototype = {
	template: function() {
		var x = 1337;
		var onClick = function() {
			x += 1;
		};
		var element_0 = window.document.createElement("button");
		element_0.setAttribute("id","hello");
		element_0.addEventListener("click",onClick);
		_$NepEl.addChild(element_0,window.document.createTextNode(x + ""));
		return element_0;
	}
};
var Main = function() { };
Main.main = function() {
	var template = new Expressions().template();
	window.document.body.appendChild(template);
};
var haxe_iterators_ArrayIterator = function(array) {
	this.current = 0;
	this.array = array;
};
haxe_iterators_ArrayIterator.prototype = {
	hasNext: function() {
		return this.current < this.array.length;
	}
	,next: function() {
		return this.array[this.current++];
	}
};
var _$NepEl = {};
_$NepEl.addChild = function(this1,child) {
	this1.appendChild(child);
	return this1;
};
Main.main();
})({});
