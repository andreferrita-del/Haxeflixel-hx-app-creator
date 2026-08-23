package runtime;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef StateEntry = {
	var name:String;
	var path:String;
	var type:String;
}

typedef DataConfig = {
	var states:Array<StateEntry>;
}

typedef InitialStateConfig = {
	var name:String;
	var path:String;
}

class RuntimeConfig {
	public static function loadData():DataConfig {
		if (FileSystem.exists("assets/src/data.json")) {
			var content = File.getContent("assets/src/data.json");
			return Json.parse(content);
		}
		return { states: [] };
	}

	public static function loadInitial():InitialStateConfig {
		if (FileSystem.exists("assets/src/initial-state.json")) {
			var content = File.getContent("assets/src/initial-state.json");
			return Json.parse(content);
		}
		return { name: "menu", path: "states/MenuState.hx" };
	}
}
