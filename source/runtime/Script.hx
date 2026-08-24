package runtime;

import hscript.Interp;
import hscript.Parser;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class Script {
	public var parser:Parser;
	public var interp:Interp;
	public var scriptPath:String;
	public var active:Bool = true;

	public function new(path:String, ?presetVariables:Map<String, Dynamic>) {
		this.scriptPath = path;

		parser = new Parser();
		interp = new Interp();

		// Suporte a sintaxe moderna
		parser.allowTypes = true;
		parser.allowJSON = true;

		// Injeção de variáveis/classes globais
		set("Json", Json);
		set("File", File);
		set("FileSystem", FileSystem);

		set("FlxG", FlxG);
		set("FlxSprite", FlxSprite);
		set("FlxText", FlxText);
		set("FlxTween", FlxTween);
		set("FlxEase", FlxEase);
		set("FlxTimer", FlxTimer);
		set("Math", Math);
		set("Std", Std);
		set("StringTools", StringTools);

		set("FlxColor", {
			TRANSPARENT: 0x00000000,
			WHITE: 0xFFFFFFFF,
			BLACK: 0xFF000000,
			RED: 0xFFFF0000,
			GREEN: 0xFF00FF00,
			BLUE: 0xFF0000FF,
			YELLOW: 0xFFFFFF00,
			CYAN: 0xFF00FFFF,
			MAGENTA: 0xFFFF00FF,
			PURPLE: 0xFF800080
		});

		if (presetVariables != null) {
			for (key in presetVariables.keys()) {
				set(key, presetVariables.get(key));
			}
		}

		executeScript();
	}

	public function set(name:String, value:Dynamic):Void {
		interp.variables.set(name, value);
	}

	public function get(name:String):Dynamic {
		return interp.variables.get(name);
	}

	private function executeScript():Void {
		if (FileSystem.exists(scriptPath)) {
			try {
				var code:String = File.getContent(scriptPath);
				var ast = parser.parseString(code, scriptPath);
				interp.execute(ast);
			} catch (e:Dynamic) {
				FlxG.log.error('Erro ao compilar/executar $scriptPath: $e');
			}
		} else {
			FlxG.log.error("Script não encontrado: " + scriptPath);
		}
	}

	public function callFunction(funcName:String, ?args:Array<Dynamic>):Dynamic {
		if (!active) return null;

		if (interp.variables.exists(funcName)) {
			var func = interp.variables.get(funcName);
			if (Reflect.isFunction(func)) {
				try {
					return Reflect.callMethod(null, func, args != null ? args : []);
				} catch (e:Dynamic) {
					FlxG.log.error('Erro ao rodar "$funcName" em $scriptPath: $e');
				}
			}
		}
		return null;
	}
}
