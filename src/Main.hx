import js.Browser;

class Main {
	static function main() {
		var helloWorld = new HelloWorld();
		var template = helloWorld.template();
		trace(template);
		// Browser.document.body.appendChild(template);
	}
}
