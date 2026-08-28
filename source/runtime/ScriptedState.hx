package runtime;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import sys.FileSystem;
import runtime.RuntimeConfig;
import haxe.io.Path;

class ScriptedState extends FlxState {
	public var scriptPath:String;
	public var scripts:ScriptGroup;
	public var dataConfig:DataConfig;
	public var initialConfig:InitialStateConfig;

	public function new(?scriptPath:String) {
		super();
		
		this.dataConfig = RuntimeConfig.loadData();
		this.initialConfig = RuntimeConfig.loadInitial();

		// Usa o caminho passado ou busca o padrão do JSON
		this.scriptPath = (scriptPath != null) ? scriptPath : this.initialConfig.path;
		this.scripts = new ScriptGroup();
	}

	override public function create():Void {
		super.create();

		// Tenta encontrar o arquivo usando a função de resolução
		var resolvedPath = resolvePath(scriptPath);

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

	// Localizador de arquivos inteligente
	private function resolvePath(relativePath:String):String {
		var p = relativePath;
		
		// Garante que a extensão .hx exista
		if (!StringTools.endsWith(p, ".hx")) p += ".hx";

		var exeDir:String = Path.directory(Sys.programPath());

		// 1. Tenta achar na build compilada (perto do .exe)
		var path1:String = Path.join([exeDir, "assets/src", p]);
		if (FileSystem.exists(path1)) return path1;

		// 2. Tenta achar no modo de teste do Haxe (Lime/OpenFL)
		var path2:String = Path.join(["assets/src", p]);
		if (FileSystem.exists(path2)) return path2;

		// 3. Tenta o caminho direto
		if (FileSystem.exists(p)) return p;

		return null;
	}
}
