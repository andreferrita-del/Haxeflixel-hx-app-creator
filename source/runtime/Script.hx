package runtime;

import hscript.Interp;
import hscript.Parser;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.Http;

// Flixel Core
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.text.FlxText;

// Utilities & Math
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
import flixel.math.FlxAngle;

// Tweens & Timers
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.FlxSave;

// Audio & Groups
import flixel.sound.FlxSound;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;

// Flixel Addons
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.transition.FlxTransitionableState;

// Flixel UI
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUIInputText;

class Script {
	public var parser:Parser;
	public var interp:Interp;
	public var scriptPath:String;
	public var active:Bool = true;

	public function new(path:String, ?presetVariables:Map<String, Dynamic>) {
		this.scriptPath = path;

		parser = new Parser();
		interp = new Interp();

		parser.allowTypes = true;
		parser.allowJSON = true;

		// Haxe Base Utilities
		set("Math", Math);
		set("Std", Std);
		set("StringTools", StringTools);
		set("Json", Json);
		set("File", File);
		set("FileSystem", FileSystem);
		set("Http", Http);
		set("Reflect", Reflect);
		set("Type", Type);

		// Flixel Core Classes
		set("FlxG", FlxG);
		set("FlxSprite", FlxSprite);
		set("FlxState", FlxState);
		set("FlxSubState", FlxSubState);
		set("FlxBasic", FlxBasic);
		set("FlxObject", FlxObject);
		set("FlxCamera", FlxCamera);
		set("FlxText", FlxText);

		// Math & Geometrics
		set("FlxMath", FlxMath);
		set("FlxVelocity", FlxVelocity);
		set("FlxAngle", FlxAngle);

		// Animation, Tweens & Effects
		set("FlxTween", FlxTween);
		set("FlxEase", FlxEase);
		set("FlxTimer", FlxTimer);
		set("FlxSave", FlxSave);
		set("FlxSound", FlxSound);
		set("FlxGroup", FlxGroup);
		set("FlxTypedGroup", FlxTypedGroup);
		set("FlxSpriteGroup", FlxSpriteGroup);

		// Addons
		set("FlxBackdrop", FlxBackdrop);
		set("FlxGridOverlay", FlxGridOverlay);
		set("FlxEffectSprite", FlxEffectSprite);
		set("FlxTransitionableState", FlxTransitionableState);

		// UI Elements
		set("FlxUIState", FlxUIState);
		set("FlxUIButton", FlxUIButton);
		set("FlxUIText", FlxUIText);
		set("FlxUIInputText", FlxUIInputText);

		// FlxColor Abstract Mapping
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
			PURPLE: 0xFF800080,
			ORANGE: 0xFFFFA500,
			GRAY: 0xFF808080,
			BROWN: 0xFF8B4513,
			PINK: 0xFFFFC0CB,
			fromRGB: FlxColor.fromRGB,
			fromHSB: FlxColor.fromHSB,
			fromString: FlxColor.fromString
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
				FlxG.log.error('Erro ao interpretar o script $scriptPath: $e');
			}
		} else {
			FlxG.log.error("Script não encontrado no caminho: " + scriptPath);
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
					FlxG.log.error('Erro ao executar "$funcName" no script $scriptPath: $e');
				}
			}
		}
		return null;
	}
}
