package runtime;

import flixel.FlxState;
import flixel.FlxG;

class RuntimeLoader {
	public static function getInitialState():Class<FlxState> {
		return DynamicStateWrapper;
	}

	public static function switchStateByName(stateName:String):Void {
		var config = RuntimeConfig.loadData();
		for (s in config.states) {
			if (s.name == stateName) {
				FlxG.switchState(new ScriptState(s.path));
				return;
			}
		}
		RuntimeErrorHandler.showError("State Missing", "assets/src/data.json", 0, 0, "State '" + stateName + "' is not registered in data.json.", "");
	}
}

class DynamicStateWrapper extends FlxState {
	override public function create():Void {
		super.create();
		try {
			var initial = RuntimeConfig.loadInitial();
			FlxG.switchState(new ScriptState(initial.path));
		} catch (e:Dynamic) {
			RuntimeErrorHandler.showError("Initialization Error", "assets/src/initial-state.json", 0, 0, Std.string(e), "");
		}
	}
}
