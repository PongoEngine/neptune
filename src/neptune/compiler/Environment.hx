package neptune.compiler;

class Environment {
	public function new():Void {}

	public function child():Environment {
		return new Environment();
	}
}
