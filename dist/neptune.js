// Generated by Haxe 4.1.3
(function ($global) { "use strict";
var HelloWorld = function() {
	this.giibye = "woah";
	this.hello = "Hi";
};
HelloWorld.prototype = {
	template: function() {
		console.log("src/HelloWorld.hx:31:",2);
		return "<h1 onclick={changeX}>{x}{y}{z}{hello}</h1>";
	}
};
var Main = function() { };
Main.main = function() {
	console.log("src/Main.hx:6:",new HelloWorld().template());
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
var neptune_lib_Runtime = function() { };
neptune_lib_Runtime.createElement = function(tagname) {
	return window.document.createElement(tagname);
};
neptune_lib_Runtime.createText = function(text) {
	return window.document.createTextNode(text);
};
neptune_lib_Runtime.updateDependencies = function(cbs) {
	var _g = 0;
	while(_g < cbs.length) cbs[_g++]();
};
neptune_lib_Runtime.updateTextNode = function(text,content) {
	return function() {
		text.textContent = content;
	};
};
neptune_lib_Runtime.addTextNode = function(text,a,b) {
	return function() {
		text.textContent = a + b;
	};
};
neptune_lib_Runtime.addAttr = function(element,attrName,attrValue) {
	element.setAttribute(attrName,attrValue);
};
neptune_lib_Runtime.removeAttr = function(element,attrName) {
	element.removeAttribute(attrName);
};
neptune_lib_Runtime.addAttrEvent = function(element,attrName,attrValue) {
	element.addEventListener("click",attrValue);
};
neptune_lib_Runtime.removeAttrEvent = function(element,attrName,attrValue) {
	element.removeEventListener(attrName,attrValue);
};
neptune_lib_Runtime.addChild = function(element,child) {
	element.appendChild(child);
};
neptune_lib_Runtime.removeChild = function(element,child) {
	element.removeChild(child);
};
Main.main();
})({});
