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

		/*
        * a path of script
		*/
		addChild(new FlxGame(1280, 720, function() return new ScriptedState(Script.scriptPath), 60, 60, true));
	}

	private function ensureRuntimeEnvironment():Void {
		if (!FileSystem.exists("assets/src")) FileSystem.createDirectory("assets/src");
		//if (!FileSystem.exists("assets/src/states")) FileSystem.createDirectory("assets/src/states");

		/*if (!FileSystem.exists("assets/src/app-name.txt")) {
			File.saveContent("assets/src/app-name.txt", "Meu Jogo");
		}*/

		// Cria o script padrão do MenuState com Package e Imports se não existir
		/*if (!FileSystem.exists("assets/src/states/MenuState.hx")) {
			var menuScript = 
'package states;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

var logo:FlxSprite;
var titleText:FlxText;

function create() {
	titleText = new FlxText(0, 150, FlxG.width, "Codename Engine Runtime", 36);
	titleText.alignment = "center";
	titleText.color = FlxColor.CYAN;
	add(titleText);

	logo = new FlxSprite(FlxG.width / 2 - 50, 320);
	logo.makeGraphic(100, 100, FlxColor.PURPLE);
	add(logo);
}

function update(elapsed:Float) {
	logo.angle += 150 * elapsed;

	if (FlxG.keys.justPressed.SPACE) {
		FlxG.camera.flash(FlxColor.WHITE, 0.4);
	}
}

function onDestroy() {
	// Cleanup extra
}';
			File.saveContent("assets/src/states/MenuState.hx", menuScript);
		}*/
	}
}
