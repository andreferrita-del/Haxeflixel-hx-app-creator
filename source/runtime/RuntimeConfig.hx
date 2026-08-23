package runtime;

import haxe.Json;

#if sys
import sys.filesystem.File;
#end

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
		#if sys
		var content = File.getContent("assets/src/data.json");
		return Json.parse(content);
		#else
		return { states: [] };
		#end
	}

	public static function loadInitial():InitialStateConfig {
		#if sys
		var content = File.getContent("assets/src/initial-state.json");
		return Json.parse(content);
		#end
	}
}
