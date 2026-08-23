package runtime;

import openfl.events.UncaughtErrorEvent;
import openfl.Lib;
import flixel.FlxG;

class RuntimeErrorHandler {
	public static function init():Void {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
	}

	private static function onError(event:UncaughtErrorEvent):Void {
		event.preventDefault();
		event.stopImmediatePropagation();

		var errorMessage:String = "Erro em Runtime Detectado:\n" + Std.string(event.error);
		FlxG.log.error(errorMessage);
		
		trace(errorMessage);
	}
}
