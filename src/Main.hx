import js.Browser;

class Main {
	static function main() {
		var helloWorld = new HelloWorld();
		Browser.document.body.appendChild(helloWorld.template());
	}
}
