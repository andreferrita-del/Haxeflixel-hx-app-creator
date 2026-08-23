package;

import flixel.FlxGame;
import openfl.display.Sprite;

#if sys
import sys.filesystem.File;
import sys.filesystem.FileSystem;
#end

import runtime.RuntimeLoader;
import runtime.RuntimeErrorHandler;

class Main extends Sprite {
	public function new() {
		super();
		
		RuntimeErrorHandler.init();

		var appName:String = "HaxeFlixel App";
		#if sys
		if (FileSystem.exists("assets/src/app-name.txt")) {
			appName = StringTools.trim(File.getContent("assets/src/app-name.txt"));
		}
		#end
		
		#if desktop
		openfl.Lib.current.stage.window.title = appName;
		#end

		addChild(new FlxGame(1280, 720, RuntimeLoader.getInitialState(), 60, 60, true));
	}
}
