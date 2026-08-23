package runtime;

import flixel.FlxState;
import sys.FileSystem;
import sys.io.File;

// Importação dinâmica com base na versão do SScript instalada
#if (sscript >= "20.0.0")
import hscript.SScript;
#elseif (sscript >= "3.0.0")
import tea.backend.SScript;
#else
import SScript;
#end

class ScriptState extends FlxState {
	public var scriptPath:String;
	public var script:SScript;

	public function new(scriptPath:String) {
		super();
		this.scriptPath = scriptPath;
	}

	override public function create():Void {
		var fullPath = "assets/src/" + scriptPath;

		if (!FileSystem.exists(fullPath)) {
			RuntimeErrorHandler.showError(
				"Arquivo Não Encontrado",
				fullPath,
				0, 0,
				"O arquivo de script especificado não existe.",
				""
			);
			return;
		}

		try {
			script = new SScript(fullPath);
			script.set("state", this);
			script.set("FlxG", flixel.FlxG);
			script.set("FlxSprite", flixel.FlxSprite);
			script.set("FlxText", flixel.text.FlxText);
			script.set("FlxColor", flixel.util.FlxColor);
			script.set("ScriptState", ScriptState);
			script.set("RuntimeLoader", RuntimeLoader);
			
			script.execute();

			if (script.exists("onCreate")) {
				script.call("onCreate");
			}
		} catch (e:Dynamic) {
			RuntimeErrorHandler.handleScriptError(fullPath, e, script);
		}

		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (script != null && script.exists("onUpdate")) {
			try {
				script.call("onUpdate", [elapsed]);
			} catch (e:Dynamic) {
				RuntimeErrorHandler.handleScriptError("assets/src/" + scriptPath, e, script);
			}
		}
	}
}
