// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var Main = function() { };
Main.main = function() {
	var template = new capabilities_Capabilities().template();
	window.document.body.appendChild(template);
};
var capabilities_Capabilities = function() {
};
capabilities_Capabilities.prototype = {
	template: function() {
		var x = 30;
		var var_2 = window.document.createTextNode(x);
		var set_x = function(val) {
			x = val;
			var_2.textContent = x;
		};
		var var_0 = window.document.createTextNode(210);
		var incrementX = function() {
			set_x(x + 1);
		};
		var var_3 = window.document.createElement("div");
		var tmp = window.document.createTextNode(" ");
		var tmp1 = capabilities_StaticFunctions.render();
		var tmp2 = window.document.createTextNode(" ");
		var tmp3 = capabilities_Constant.render();
		var tmp4 = window.document.createTextNode(" ");
		var tmp5 = capabilities_ForLoops.render(200);
		var tmp6 = window.document.createTextNode(" ");
		var tmp7 = capabilities_Markup.render();
		var tmp8 = window.document.createTextNode(" ");
		var var_1 = window.document.createElement("button");
		neptune_platform_html_HtmlPlatform.addChildren(var_1,[window.document.createTextNode("Increment X"),var_0]);
		var_1.onclick = incrementX;
		neptune_platform_html_HtmlPlatform.addChildren(var_3,[tmp,tmp1,tmp2,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8,var_1,window.document.createTextNode(" "),var_2,window.document.createTextNode(" ")]);
		return var_3;
	}
};
var capabilities_Constant = function() { };
capabilities_Constant.render = function() {
	var var_5 = window.document.createElement("p");
	neptune_platform_html_HtmlPlatform.addChildren(var_5,[window.document.createTextNode(" "),window.document.createTextNode("Hi"),window.document.createTextNode(" ")]);
	return var_5;
};
var capabilities_ForLoops = function() { };
capabilities_ForLoops.render = function(length) {
	var var_6 = window.document.createElement("div");
	var tmp = window.document.createTextNode(" ");
	var frag = window.document.createDocumentFragment();
	var _g = 0;
	while(_g < length) frag.appendChild(capabilities_ForLoops.blah(_g++));
	neptune_platform_html_HtmlPlatform.addChildren(var_6,[tmp,frag,window.document.createTextNode(" ")]);
	return var_6;
};
capabilities_ForLoops.blah = function(val) {
	var var_7 = window.document.createTextNode(val);
	var var_8 = window.document.createElement("h1");
	neptune_platform_html_HtmlPlatform.addChildren(var_8,[window.document.createTextNode("Hi "),var_7]);
	return var_8;
};
var capabilities_Markup = function() { };
capabilities_Markup.render = function() {
	var var_10 = window.document.createElement("div");
	var tmp = window.document.createTextNode(" ");
	var var_9 = window.document.createElement("h1");
	neptune_platform_html_HtmlPlatform.addChildren(var_9,[window.document.createTextNode("Markup")]);
	neptune_platform_html_HtmlPlatform.addChildren(var_10,[tmp,var_9,window.document.createTextNode(" ")]);
	return var_10;
};
var capabilities_StaticFunctions = function() { };
capabilities_StaticFunctions.render = function() {
	var var_4 = window.document.createElement("h1");
	neptune_platform_html_HtmlPlatform.addChildren(var_4,[window.document.createTextNode("Render StaticFunctions")]);
	return var_4;
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
