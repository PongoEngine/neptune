// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var HelloWorld = function() {
};
HelloWorld.prototype = {
	template: function() {
		var x = 30;
		var var_3 = window.document.createTextNode(x);
		var set_x = function(val) {
			x = val;
			var_3.textContent = x;
		};
		var isLeft = true;
		var incrementX = function() {
			set_x(x + 1);
		};
		var var_0 = window.document.createElement("h1");
		neptune_platform_html_HtmlPlatform.addChildren(var_0,[window.document.createTextNode("Left")]);
		var left = var_0;
		var var_1 = window.document.createElement("h1");
		neptune_platform_html_HtmlPlatform.addChildren(var_1,[window.document.createTextNode("Right")]);
		var right = var_1;
		var set_isLeft = function(val) {
			isLeft = val;
			neptune_platform_html_HtmlPlatform.updateParent(isLeft,left,right);
		};
		var var_6 = isLeft ? left : right;
		var toggleIsLeft = function() {
			set_isLeft(!isLeft);
		};
		var var_7 = window.document.createElement("div");
		var tmp = window.document.createTextNode(" ");
		var var_2 = window.document.createElement("button");
		neptune_platform_html_HtmlPlatform.addChildren(var_2,[window.document.createTextNode("Increment X")]);
		var_2.onclick = incrementX;
		var tmp1 = window.document.createTextNode(" ");
		var var_4 = window.document.createElement("h2");
		neptune_platform_html_HtmlPlatform.addChildren(var_4,[var_3]);
		var tmp2 = window.document.createTextNode(" ");
		var var_5 = window.document.createElement("button");
		neptune_platform_html_HtmlPlatform.addChildren(var_5,[window.document.createTextNode("Toggle IsLeft")]);
		var_5.onclick = toggleIsLeft;
		neptune_platform_html_HtmlPlatform.addChildren(var_7,[tmp,var_2,tmp1,var_4,tmp2,var_5,window.document.createTextNode(" "),var_6,window.document.createTextNode(" ")]);
		return var_7;
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
neptune_platform_html_HtmlPlatform.updateParent = function(condition,left,right) {
	if(condition) {
		right.parentNode.replaceChild(left,right);
	} else {
		left.parentNode.replaceChild(right,left);
	}
};
neptune_platform_html_HtmlPlatform.addChildren = function(element,children) {
	var _g = 0;
	while(_g < children.length) element.appendChild(children[_g++]);
	return element;
};
Main.main();
})({});
