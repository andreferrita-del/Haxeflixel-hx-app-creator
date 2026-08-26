package runtime;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import sys.FileSystem;
import haxe.io.Path;

class ScriptedState extends FlxState {
	public var scriptPath:String;
	public var scripts:ScriptGroup;

	public function new(scriptPath:String) {
		super();
		this.scriptPath = scriptPath;
		
		if (!StringTools.endsWith(this.scriptPath, ".hx")) {
			this.scriptPath += ".hx";
		}

		this.scripts = new ScriptGroup();
	}

	override public function create():Void {
		super.create();

		var resolvedPath:String = getAbsoluteAssetPath(scriptPath);

		if (resolvedPath == null || !FileSystem.exists(resolvedPath)) {
			var errorText = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "Erro: Arquivo não encontrado!\n" + scriptPath, 20);
			errorText.alignment = "center";
			errorText.color = 0xFFFF0000;
			add(errorText);
			FlxG.log.error("Arquivo não encontrado no caminho: " + scriptPath);
			return;
		}

		var presetVars:Map<String, Dynamic> = [
			"state" => this,
			"add" => function(basic:flixel.FlxBasic) return add(basic),
			"remove" => function(basic:flixel.FlxBasic) return remove(basic),
			"insert" => function(position:Int, basic:flixel.FlxBasic) return insert(position, basic)
		];

		scripts.addScript(resolvedPath, presetVars);
		
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

	private function getAbsoluteAssetPath(relativePath:String):String {
		// Pega o diretório do próprio executável .exe
		var exeDir:String = Path.directory(Sys.programPath());

		// 1. Tenta achar na pasta do executável
		var path1:String = Path.join([exeDir, "assets/src", relativePath]);
		if (FileSystem.exists(path1)) return path1;

		// 2. Tenta achar no diretório relativo atual
		var path2:String = Path.join(["assets/src", relativePath]);
		if (FileSystem.exists(path2)) return path2;

		// 3. Tenta direto
		if (FileSystem.exists(relativePath)) return relativePath;

		return null;
	}
}
