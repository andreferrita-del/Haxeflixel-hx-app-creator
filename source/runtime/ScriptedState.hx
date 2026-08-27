package runtime;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;
import sys.FileSystem;

class ScriptedState extends FlxState {
	public var scriptPath:String;
	public var scripts:ScriptGroup;
	public var dataConfig:DataConfig;
	public var initialConfig:InitialStateConfig;

	public function new(?scriptPath:String) {
		super();
		
		// Carrega as configurações via JSON
		this.dataConfig = RuntimeConfig.loadData();
		this.initialConfig = RuntimeConfig.loadInitial();

		// Usa o caminho passado ou busca o caminho padrão do JSON
		this.scriptPath = (scriptPath != null) ? scriptPath : this.initialConfig.path;
		this.scripts = new ScriptGroup();
	}

	override public function create():Void {
		super.create();

		if (!FileSystem.exists(scriptPath)) {
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

		scripts.addScript(scriptPath, presetVars);
		
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
