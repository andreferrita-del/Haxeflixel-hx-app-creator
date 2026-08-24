package runtime;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import flixel.FlxState;

typedef InitialStateData = {
	var name:String;
	var path:String;
}

class RuntimeLoader {
	public static function getInitialState():Dynamic {
		var stateName:String = "MenuState"; // Nome padrão de fallback

		var jsonPath:String = "assets/src/initial-state.json";
		if (!FileSystem.exists(jsonPath)) {
			jsonPath = "./assets/src/initial-state.json";
		}

		// Se o JSON existir, lê dinamicamente qual é o estado inicial
		if (FileSystem.exists(jsonPath)) {
			try {
				var content:String = File.getContent(jsonPath);
				var parsed:InitialStateData = Json.parse(content);
				
				if (parsed != null && parsed.name != null) {
					// Remove a extensão .hx se o usuário tiver escrito no JSON por engano
					stateName = parsed.name.split(".hx")[0];
				}
			} catch (e:Dynamic) {
				trace("Erro ao ler initial-state.json: " + e);
			}
		}

		// Retorna a função construtora do ScriptedState apontando para a classe/script lida do JSON
		return function():FlxState {
			return new ScriptedState(stateName);
		};
	}
}
