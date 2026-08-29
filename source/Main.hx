package;

import flixel.FlxGame;
import openfl.display.Sprite;
import sys.FileSystem;
import sys.io.File;
import runtime.*;

class Main extends Sprite {
	public function new() {
		super();
		
		RuntimeErrorHandler.init();
		ensureRuntimeEnvironment();

		var appName:String = "My game/app name";
		if (FileSystem.exists("assets/src/app-name.txt")) {
			appName = StringTools.trim(File.getContent("assets/src/app-name.txt"));
		}
		
		openfl.Lib.current.stage.window.title = appName;

		// Inicia apontando para o script inicial Main.hx localizado dentro de assets/src/
		addChild(new FlxGame(1280, 720, function() return new ScriptedState("Main"), 60, 60, true));
	}

	private function ensureRuntimeEnvironment():Void {
		if (!FileSystem.exists("assets/src")) {
			FileSystem.createDirectory("assets/src");
		}

		if (!FileSystem.exists("assets/src/app-name.txt")) {
			File.saveContent("assets/src/app-name.txt", "Meu Jogo");
		}

		// Cria o script principal de teste caso não exista
		if (!FileSystem.exists("assets/src/Main.hx")) {
			var mainScript = 
'package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

var logo:FlxSprite;
var titleText:FlxText;

function create() {
	titleText = new FlxText(0, 150, FlxG.width, "Runtime Engine Loaded!", 36);
	titleText.alignment = "center";
	titleText.color = FlxColor.CYAN;
	add(titleText);

	logo = new FlxSprite(FlxG.width / 2 - 50, 320);
	logo.makeGraphic(100, 100, FlxColor.PURPLE);
	add(logo);
}

function update(elapsed:Float) {
	if (logo != null) {
		logo.angle += 150 * elapsed;
	}

	if (FlxG.keys.justPressed.SPACE) {
		FlxG.camera.flash(FlxColor.WHITE, 0.4);
	}
}

function onDestroy() {
	// Cleanup
}';
			File.saveContent("assets/src/Main.hx", mainScript);
		}
	}
}
