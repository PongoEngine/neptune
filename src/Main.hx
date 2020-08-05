import js.Browser;

class Main {
	static function main() {
		var helloWorld = new HelloWorld();
		var template = helloWorld.cool();
		Browser.document.body.appendChild(template);
	}
}
