package runtime;

class ScriptGroup {
	public var scripts:Array<Script> = [];

	public function new() {}

	public function addScript(path:String, ?presetVariables:Map<String, Dynamic>):Script {
		var script = new Script(path, presetVariables);
		scripts.push(script);
		return script;
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Void {
		for (script in scripts) {
			if (script != null && script.active) {
				script.callFunction(funcName, args);
			}
		}
	}

	public function setAll(variable:String, value:Dynamic):Void {
		for (script in scripts) {
			if (script != null) script.set(variable, value);
		}
	}

	public function destroy():Void {
		for (script in scripts) {
			script.active = false;
		}
		scripts = [];
	}
}
