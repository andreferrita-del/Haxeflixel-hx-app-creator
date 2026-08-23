package;

import flixel.FlxGame;
import openfl.display.Sprite;
import sys.FileSystem;
import sys.io.File;
import runtime.RuntimeLoader;
import runtime.RuntimeErrorHandler;

class Main extends Sprite {
	public function new() {
		super();
		
		RuntimeErrorHandler.init();

		var appName:String = "HaxeFlixel App";
		
		if (FileSystem.exists("assets/src/app-name.txt")) {
			appName = StringTools.trim(File.getContent("assets/src/app-name.txt"));
		}
		
		openfl.Lib.current.stage.window.title = appName;

		addChild(new FlxGame(1280, 720, RuntimeLoader.getInitialState(), 60, 60, true));
	}
}
