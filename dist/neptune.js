// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var Expressions = function() {
};
Expressions.prototype = {
	template: function() {
		var set_x = function(val) {
		};
		var x = 0;
		var onClick = function() {
			set_x(x + 1);
		};
		var frag = window.document.createElement("div");
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		var element_div_0 = window.document.createElement("div");
		neptune_platform_html_HtmlPlatform.addChildren(element_div_0,[window.document.createTextNode("Hi")]);
		frag.appendChild(element_div_0);
		set_x = function(val) {
			x = val;
		};
		var element_div_4 = window.document.createElement("div");
		var tmp = window.document.createTextNode(" ");
		var tmp1 = window.document.createTextNode(" ");
		var element_button_3 = window.document.createElement("button");
		neptune_platform_html_HtmlPlatform.addChildren(element_button_3,[window.document.createTextNode("Action")]);
		element_button_3.onclick = onClick;
		neptune_platform_html_HtmlPlatform.addChildren(element_div_4,[tmp,frag,tmp1,element_button_3,window.document.createTextNode(" ")]);
		return element_div_4;
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
var neptune_platform_html_HtmlPlatform = function() { };
neptune_platform_html_HtmlPlatform.addChildren = function(element,children) {
	var _g = 0;
	while(_g < children.length) element.appendChild(children[_g++]);
	return element;
};
Main.main();
})({});
