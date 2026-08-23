package runtime;

import flixel.FlxState;
import sys.FileSystem;
import sys.io.File;

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
			RuntimeErrorHandler.showError("Arquivo Não Encontrado", fullPath, 0, 0, "O arquivo de script especificado não existe.", "");
			return;
		}

		try {
			script = new SScript(fullPath);
			
			// Contexto do Runtime Host
			script.set("state", this);
			script.set("ScriptState", ScriptState);
			script.set("RuntimeLoader", RuntimeLoader);

			// Haxe Core & Sys
			script.set("Math", Math);
			script.set("Std", Std);
			script.set("StringTools", StringTools);
			script.set("Date", Date);
			script.set("DateTools", DateTools);
			script.set("Reflect", Reflect);
			script.set("Type", Type);
			script.set("Lambda", Lambda);
			script.set("Json", haxe.Json);
			script.set("File", sys.io.File);
			script.set("FileSystem", sys.FileSystem);

			// Flixel Core
			script.set("FlxG", flixel.FlxG);
			script.set("FlxObject", flixel.FlxObject);
			script.set("FlxSprite", flixel.FlxSprite);
			script.set("FlxState", flixel.FlxState);
			script.set("FlxSubState", flixel.FlxSubState);
			script.set("FlxBasic", flixel.FlxBasic);
			script.set("FlxCamera", flixel.FlxCamera);
			script.set("FlxGame", flixel.FlxGame);

			// Flixel Groups & Tilemaps
			script.set("FlxGroup", flixel.group.FlxGroup);
			script.set("FlxTypedGroup", flixel.group.FlxGroup.FlxTypedGroup);
			script.set("FlxSpriteGroup", flixel.group.FlxSpriteGroup);
			script.set("FlxTilemap", flixel.tile.FlxTilemap);
			script.set("FlxBaseTilemap", flixel.tile.FlxBaseTilemap);

			// Flixel UI & Text
			script.set("FlxText", flixel.text.FlxText);
			script.set("FlxTextFormat", flixel.text.FlxText.FlxTextFormat);
			script.set("FlxButton", flixel.ui.FlxButton);
			script.set("FlxBar", flixel.ui.FlxBar);
			script.set("FlxSpriteButton", flixel.ui.FlxSpriteButton);

			// Flixel Tweens, Ease & Timers
			script.set("FlxTween", flixel.tweens.FlxTween);
			script.set("FlxEase", flixel.tweens.FlxEase);
			script.set("FlxTimer", flixel.util.FlxTimer);

			// Flixel Math & Utilities
			script.set("FlxColor", flixel.util.FlxColor);
			script.set("FlxMath", flixel.math.FlxMath);
			script.set("FlxPoint", flixel.math.FlxPoint);
			script.set("FlxRect", flixel.math.FlxRect);
			script.set("FlxVector", flixel.math.FlxVector);
			script.set("FlxRandom", flixel.math.FlxRandom);
			script.set("FlxVelocity", flixel.math.FlxVelocity);
			script.set("FlxAngle", flixel.math.FlxAngle);
			script.set("FlxSave", flixel.util.FlxSave);
			script.set("FlxSort", flixel.util.FlxSort);
			script.set("FlxDestroyUtil", flixel.util.FlxDestroyUtil);

			// Flixel Audio, Graphics & Effects
			script.set("FlxSound", flixel.sound.FlxSound);
			script.set("FlxSoundGroup", flixel.sound.FlxSoundGroup);
			script.set("FlxEmitter", flixel.effects.particles.FlxEmitter);
			script.set("FlxParticle", flixel.effects.particles.FlxParticle);
			script.set("FlxBackdrop", flixel.addons.display.FlxBackdrop);
			script.set("FlxTiledMap", flixel.addons.editors.tiled.FlxTiledMap);

			// OpenFL / Lime Layer
			script.set("Assets", openfl.utils.Assets);
			script.set("BitmapData", openfl.display.BitmapData);
			script.set("Sprite", openfl.display.Sprite);
			script.set("TextField", openfl.text.TextField);
			script.set("TextFormat", openfl.text.TextFormat);
			script.set("Sound", openfl.media.Sound);

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
