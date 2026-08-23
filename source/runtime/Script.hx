package runtime;

import hscript.SScript;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class Script extends SScript {
	public var scriptPath:String;

	public function new(path:String, ?presetVariables:Map<String, Dynamic>) {
		super();
		this.scriptPath = path;

		// Configurações identicas ao comportamento da CNE
		this.traces = true;
		
		// Injeção de Bibliotecas e Classes do Flixel
		set("FlxG", FlxG);
		set("FlxSprite", FlxSprite);
		set("FlxText", FlxText);
		set("FlxTween", FlxTween);
		set("FlxEase", FlxEase);
		set("FlxTimer", FlxTimer);
		set("Math", Math);
		set("Std", Std);
		set("StringTools", StringTools);

		// Passa variáveis iniciais de contexto se existirem
		if (presetVariables != null) {
			for (key in presetVariables.keys()) {
				set(key, presetVariables.get(key));
			}
		}

		// Carrega e executa o código
		if (FileSystem.exists(path)) {
			doFile(path);
		} else {
			FlxG.log.error("Script não encontrado no caminho: " + path);
		}
	}

	// Execução segura de funções enviando argumentos (como no CNE)
	public function callFunction(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (!active || !exists(funcName)) return null;

		try {
			return call(funcName, args != null ? args : []);
		} catch (e:Dynamic) {
			FlxG.log.error('Erro ao chamar "$funcName" em $scriptPath: $e');
			return null;
		}
	}

}
