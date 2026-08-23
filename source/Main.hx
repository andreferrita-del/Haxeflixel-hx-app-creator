package;

import flixel.FlxGame;
import openfl.display.Sprite;
import sys.filesystem.File;
import sys.filesystem.FileSystem;
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
		
		#if desktop
		openfl.Lib.current.stage.window.title = appName;
		#end

		addChild(new FlxGame(1280, 720, RuntimeLoader.getInitialState(), 60, 60, true));
	}
}
