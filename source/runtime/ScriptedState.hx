package runtime;

import flixel.FlxState;
import flixel.FlxG;

class ScriptedState extends FlxState {
	public var scriptName:String;
	public var scripts:ScriptGroup;

	public function new(scriptName:String) {
		super();
		this.scriptName = scriptName;
		this.scripts = new ScriptGroup();
	}

	override public function create():Void {
		super.create();

		var path:String = "assets/src/states/" + scriptName + ".hx";
		
		var presetVars:Map<String, Dynamic> = [
			"state" => this,
			"add" => add,
			"remove" => remove,
			"insert" => insert
		];

		scripts.addScript(path, presetVars);
		
		scripts.call("create", []);
		scripts.call("postCreate", []);
	}

	override public function update(elapsed:Float):Void {
		scripts.call("update", [elapsed]);
		super.update(elapsed);
		scripts.call("postUpdate", [elapsed]);
	}

	override public function destroy():Void {
		scripts.call("onDestroy", []);
		scripts.destroy();
		super.destroy();
	}
}
