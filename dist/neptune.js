// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var HelloWorld = function() {
};
HelloWorld.prototype = {
	template: function() {
		var name = "Jeremy";
		var var_2 = window.document.createTextNode(name);
		var var_0 = window.document.createTextNode(name);
		var set_name = null;
		set_name = function(new_name) {
			set_name(new_name);
			var_0.textContent = name;
		};
		var var_3 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(var_3,[window.document.createTextNode("Hello "),var_2]);
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
