package runtime;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import sys.FileSystem;

class ScriptedState extends FlxState {
	public var scriptPath:String;
	public var scripts:ScriptGroup;

	public function new(scriptPath:String) {
		super();
		this.scriptPath = scriptPath;
		
		// Trava de segurança para garantir o .hx no final do caminho
		if (!StringTools.endsWith(this.scriptPath, ".hx")) {
			this.scriptPath += ".hx";
		}

		this.scripts = new ScriptGroup();
	}

	override public function create():Void {
		super.create();

		var fullPath:String = "assets/src/" + scriptPath;
		if (!FileSystem.exists(fullPath)) {
			fullPath = "./assets/src/" + scriptPath;
		}

		if (!FileSystem.exists(fullPath)) {
			var errorText = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "Erro: " + scriptPath + " não foi encontrado!", 24);
			errorText.alignment = "center";
			errorText.color = 0xFFFF0000;
			add(errorText);
			FlxG.log.error("Arquivo de script não encontrado: " + fullPath);
			return;
		}

		var presetVars:Map<String, Dynamic> = [
			"state" => this,
			"add" => function(basic:flixel.FlxBasic) return add(basic),
			"remove" => function(basic:flixel.FlxBasic) return remove(basic),
			"insert" => function(position:Int, basic:flixel.FlxBasic) return insert(position, basic)
		];

		scripts.addScript(fullPath, presetVars);
		
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
