package runtime;

import flash.events.UncaughtErrorEvent;
import openfl.Lib;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.display.Sprite;
import sys.FileSystem;
import sys.io.File;

class RuntimeErrorHandler {
	public static function init():Void {
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
	}

	private static function onUncaughtError(e:UncaughtErrorEvent):Void {
		e.preventDefault();
		showError("Runtime Exception", "Desconhecido", 0, 0, Std.string(e.error), haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
	}

	public static function handleScriptError(filePath:String, e:Dynamic, script:Dynamic):Void {
		var line:Int = 0;
		var msg:String = Std.string(e);
		
		if (script != null && Reflect.hasField(script, "parsingError") && Reflect.field(script, "parsingError") != null) {
			var err = Reflect.field(script, "parsingError");
			msg = Std.string(Reflect.field(err, "message"));
			line = Std.int(Reflect.field(err, "line"));
		}

		showError("Erro de Script", filePath, line, 0, msg, haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
	}

	public static function showError(type:String, file:String, line:Int, col:Int, msg:String, stack:String):Void {
		var modal = new Sprite();
		modal.graphics.beginFill(0x1E1E1E, 0.95);
		modal.graphics.drawRoundRect(100, 50, 1080, 620, 16, 16);
		modal.graphics.endFill();

		var tf = new TextField();
		tf.x = 120;
		tf.y = 70;
		tf.width = 1040;
		tf.height = 500;
		tf.multiline = true;
		tf.wordWrap = true;
		tf.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF);

		var codeSnippet = "";
		if (FileSystem.exists(file) && line > 0) {
			var lines = File.getContent(file).split("\n");
			var start = lines[line - 3] != null ? line - 3 : 0;
			var end = lines[line + 1] != null ? line + 1 : lines.length - 1;
			codeSnippet = "\n\nCódigo ao redor da linha " + line + ":\n";
			for (i in start...end + 1) {
				var prefix = (i + 1 == line) ? " > " : "   ";
				codeSnippet += prefix + (i + 1) + ": " + lines[i] + "\n";
			}
		}

		tf.text = '┌──────────────────────────────────────────────┐\n' +
		          '  HaxeFlixel Runtime Error\n' +
		          '├──────────────────────────────────────────────┤\n' +
		          '  Tipo: $type\n' +
		          '  Arquivo: $file\n' +
		          '  Linha: $line | Coluna: $col\n\n' +
		          '  Mensagem: $msg\n\n' +
		          '  Stack trace:\n$stack' + codeSnippet +
		          '└──────────────────────────────────────────────┘';

		modal.addChild(tf);

		var btnCopy = createButton("Copiar Erro", 120, 600, function(_) {
			openfl.system.System.setClipboard(tf.text);
		});
		
		var btnReload = createButton("Recarregar", 260, 600, function(_) {
			Lib.current.stage.removeChild(modal);
			flixel.FlxG.resetState();
		});

		var btnClose = createButton("Fechar", 400, 600, function(_) {
			Lib.current.stage.removeChild(modal);
		});

		modal.addChild(btnCopy);
		modal.addChild(btnReload);
		modal.addChild(btnClose);

		Lib.current.stage.addChild(modal);
	}

	private static function createButton(label:String, x:Float, y:Float, onClick:Dynamic->Void):Sprite {
		var btn = new Sprite();
		btn.graphics.beginFill(0x444444);
		btn.graphics.drawRoundRect(0, 0, 120, 35, 8, 8);
		btn.graphics.endFill();
		btn.x = x;
		btn.y = y;
		btn.buttonMode = true;

		var txt = new TextField();
		txt.text = label;
		txt.x = 10;
		txt.y = 8;
		txt.selectable = false;
		txt.defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFF);
		btn.addChild(txt);

		btn.addEventListener(MouseEvent.CLICK, onClick);
		return btn;
	}
}
