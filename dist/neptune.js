// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var Expressions = function() {
};
Expressions.prototype = {
	doggo: function() {
		var set_x = function(val) {
		};
		var x = 0;
		var onClick = function() {
			set_x(x + 1);
		};
		set_x = function(val) {
			x = val;
		};
		var element_div_3 = window.document.createElement("div");
		var tmp = window.document.createTextNode(" ");
		var element_span_0 = window.document.createElement("span");
		neptune_platform_html_HtmlPlatform.addChildren(element_span_0,[window.document.createTextNode("Sup")]);
		var element_h3_1 = window.document.createElement("h3");
		neptune_platform_html_HtmlPlatform.addChildren(element_h3_1,[window.document.createTextNode("Hi "),element_span_0]);
		var tmp1 = window.document.createTextNode(" ");
		var element_button_2 = window.document.createElement("button");
		neptune_platform_html_HtmlPlatform.addChildren(element_button_2,[window.document.createTextNode("Action")]);
		element_button_2.onclick = onClick;
		neptune_platform_html_HtmlPlatform.addChildren(element_div_3,[tmp,element_h3_1,tmp1,element_button_2,window.document.createTextNode(" ")]);
		return element_div_3;
	}
	,template: function() {
		var set_x = function(val) {
		};
		var x = 0;
		var onClick = function() {
			set_x(x + 1);
		};
		set_x = function(val) {
			x = val;
		};
		var element_div_7 = window.document.createElement("div");
		var tmp = window.document.createTextNode(" ");
		var element_span_4 = window.document.createElement("span");
		neptune_platform_html_HtmlPlatform.addChildren(element_span_4,[window.document.createTextNode("Sup")]);
		var element_h3_5 = window.document.createElement("h3");
		neptune_platform_html_HtmlPlatform.addChildren(element_h3_5,[window.document.createTextNode("Hi "),element_span_4]);
		var tmp1 = window.document.createTextNode(" ");
		var element_button_6 = window.document.createElement("button");
		neptune_platform_html_HtmlPlatform.addChildren(element_button_6,[window.document.createTextNode("Action")]);
		element_button_6.onclick = onClick;
		neptune_platform_html_HtmlPlatform.addChildren(element_div_7,[tmp,element_h3_5,tmp1,element_button_6,window.document.createTextNode(" "),this.doggo(),window.document.createTextNode(" ")]);
		return element_div_7;
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
