// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var HelloWorld = function() {
};
HelloWorld.prototype = {
	template: function() {
		var x = 20;
		var var_0 = window.document.createTextNode(x);
		var y = 0;
		var var_1 = window.document.createTextNode(y);
		var isX = true;
		var var_2 = isX ? var_0 : var_1;
		var onClick = function() {
			x += 1;
			y -= 1;
			isX = !isX;
		};
		var var_3 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(var_3,[var_2]);
		var_3.onclick = onClick;
		return var_3;
	}
};
var Main = function() { };
Main.main = function() {
	var template = new HelloWorld().template();
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
var neptune_platform_html_HtmlPlatform = function() { };
neptune_platform_html_HtmlPlatform.addChildren = function(element,children) {
	var _g = 0;
	while(_g < children.length) element.appendChild(children[_g++]);
	return element;
};
Main.main();
})({});
