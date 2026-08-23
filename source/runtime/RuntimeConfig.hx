package runtime;

import haxe.Json;
import sys.filesystem.File;

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
		var content = File.getContent("assets/src/data.json");
		return Json.parse(content);
	}

	public static function loadInitial():InitialStateConfig {
		var content = File.getContent("assets/src/initial-state.json");
		return Json.parse(content);
	}
}
