package runtime;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.FileSystem;
import haxe.io.Path;

class ScriptedState extends FlxState {
	public var scriptPath:String;
	public var scripts:ScriptGroup;

	public function new(?scriptPath:String) {
		super();
		this.scriptPath = (scriptPath != null && scriptPath.length > 0) ? scriptPath : "Main";
		this.scripts = new ScriptGroup();
	}

	override public function create():Void {
		super.create();

		var resolvedPath = resolvePath(scriptPath);

		if (resolvedPath == null || !FileSystem.exists(resolvedPath)) {
			var errorMsg = "Erro: Arquivo não encontrado!\n" + scriptPath;
			var errorText = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, errorMsg, 20);
			errorText.alignment = "center";
			errorText.color = FlxColor.RED;
			add(errorText);
			
			FlxG.log.error("ScriptedState: Arquivo não encontrado no caminho: " + scriptPath);
			return;
		}

		var presetVars:Map<String, Dynamic> = [
			"state" => this,
			"add" => function(basic:flixel.FlxBasic) return add(basic),
			"remove" => function(basic:flixel.FlxBasic) return remove(basic),
			"insert" => function(position:Int, basic:flixel.FlxBasic) return insert(position, basic),
			"members" => members
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
		if (scripts != null) {
			scripts.destroy();
		}
		super.destroy();
	}

	private function resolvePath(relativePath:String):String {
		if (relativePath == null || relativePath.length == 0) return null;

		var p = relativePath;
		if (!StringTools.endsWith(p, ".hx")) p += ".hx";

		var exeDir:String = Path.directory(Sys.programPath());

		// 1. Procura na pasta do executável (Release/Export)
		var path1:String = Path.join([exeDir, "assets/src", p]);
		if (FileSystem.exists(path1)) return path1;

		// 2. Procura relativo à raiz do projeto (Debug/Lime)
		var path2:String = Path.join(["assets/src", p]);
		if (FileSystem.exists(path2)) return path2;

		// 3. Tenta o caminho direto informado
		if (FileSystem.exists(p)) return p;

		return null;
	}
}
