// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var HelloWorld = function() {
};
HelloWorld.prototype = {
	template: function() {
		var x = 30;
		var var_2 = window.document.createTextNode(x);
		var set_x = function(val) {
			x = val;
			var_2.textContent = x;
		};
		var onClick = function() {
			set_x(x + 1);
		};
		neptune_platform_html_HtmlPlatform.addChildren(window.document.createElement("h1"),[window.document.createTextNode("Left")]);
		neptune_platform_html_HtmlPlatform.addChildren(window.document.createElement("h1"),[window.document.createTextNode("Right")]);
		var var_4 = window.document.createElement("div");
		var tmp = window.document.createTextNode(" ");
		var var_3 = window.document.createElement("h2");
		neptune_platform_html_HtmlPlatform.addChildren(var_3,[var_2]);
		neptune_platform_html_HtmlPlatform.addChildren(var_4,[tmp,var_3,window.document.createTextNode(" ")]);
		var_4.onclick = onClick;
		return var_4;
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
