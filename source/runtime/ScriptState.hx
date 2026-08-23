package runtime;

import flixel.FlxState;
import tea.backend.SScript;
import sys.filesystem.File;
import sys.filesystem.FileSystem;

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
				"File Not Found",
				fullPath,
				0, 0,
				"The specified script file does not exist.",
				""
			);
			return;
		}

		try {
			script = new SScript(fullPath);
			
			// Context Injection
			script.set("state", this);
			script.set("ScriptState", ScriptState);
			script.set("RuntimeLoader", RuntimeLoader);

			// Haxe Core Imports
			script.set("Math", Math);
			script.set("Std", Std);
			script.set("StringTools", StringTools);
			script.set("Date", Date);
			script.set("Reflect", Reflect);
			script.set("Type", Type);
			script.set("Json", haxe.Json);
			script.set("File", sys.filesystem.File);
			script.set("FileSystem", sys.filesystem.FileSystem);

			// Flixel Core Imports
			script.set("FlxG", flixel.FlxG);
			script.set("FlxObject", flixel.FlxObject);
			script.set("FlxSprite", flixel.FlxSprite);
			script.set("FlxState", flixel.FlxState);
			script.set("FlxSubState", flixel.FlxSubState);
			script.set("FlxBasic", flixel.FlxBasic);
			script.set("FlxCamera", flixel.FlxCamera);

			// Flixel Text & UI
			script.set("FlxText", flixel.text.FlxText);
			script.set("FlxButton", flixel.ui.FlxButton);
			script.set("FlxBar", flixel.ui.FlxBar);

			// Flixel Groups & Tilemaps
			script.set("FlxGroup", flixel.group.FlxGroup);
			script.set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
			script.set("FlxSpriteGroup", flixel.group.FlxSpriteGroup);
			script.set("FlxTilemap", flixel.tile.FlxTilemap);

			// Flixel Utils & Math
			script.set("FlxColor", flixel.util.FlxColor);
			script.set("FlxMath", flixel.math.FlxMath);
			script.set("FlxPoint", flixel.math.FlxPoint);
			script.set("FlxRect", flixel.math.FlxRect);
			script.set("FlxTimer", flixel.util.FlxTimer);
			script.set("FlxTween", flixel.tweens.FlxTween);
			script.set("FlxEase", flixel.tweens.FlxEase);
			script.set("FlxSave", flixel.util.FlxSave);

			// Flixel Audio & Effects
			script.set("FlxSound", flixel.sound.FlxSound);
			script.set("FlxEmitter", flixel.effects.particles.FlxEmitter);

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
