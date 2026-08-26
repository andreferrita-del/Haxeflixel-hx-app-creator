package runtime;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.io.Path;
import flixel.FlxState;

typedef StateData = {
	var name:String;
	var path:String;
	var type:String;
}

typedef DataJson = {
	var states:Array<StateData>;
}

class RuntimeLoader {
	public static function getInitialState():Dynamic {
		var statePath:String = "states/MenuState.hx";

		var exeDir:String = Path.directory(Sys.programPath());
		var dataPath:String = Path.join([exeDir, "assets/src/data.json"]);

		if (!FileSystem.exists(dataPath)) {
			dataPath = "assets/src/data.json";
		}

		if (FileSystem.exists(dataPath)) {
			try {
				var content:String = File.getContent(dataPath);
				var parsed:DataJson = Json.parse(content);

				if (parsed != null && parsed.states != null && parsed.states.length > 0) {
					var targetState = parsed.states[0];
					for (s in parsed.states) {
						if (s.name == "main") {
							targetState = s;
							break;
						}
					}

					if (targetState.path != null && targetState.path != "") {
						statePath = targetState.path;
						if (!StringTools.endsWith(statePath, ".hx")) {
							statePath += ".hx";
						}
					}
				}
			} catch (e:Dynamic) {
				trace("Erro ao ler data.json: " + e);
			}
		}

		return function():FlxState {
			return new ScriptedState(statePath);
		};
	}
}
