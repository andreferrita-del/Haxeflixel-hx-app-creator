package runtime;

import hscript.Parser;
import sys.FileSystem;
import sys.io.File;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

class ScriptGroup {
	public var scripts:Array<Script> = [];
	public var parser:Parser;

	// Dicionário global com todas as classes registradas via Macro e Runtime
	public static var importsMap:Map<String, Dynamic> = new Map<String, Dynamic>();

	// =========================================================================
	// INICIALIZAÇÃO E MACROS DO ENGINE
	// =========================================================================
	static function __init__() {
		#if !macro
		// Injeta as classes mapeadas pela Macro direto na inicialização
		var macroClasses:Map<String, Dynamic> = initMacroImports();
		for (key => val in macroClasses) {
			if (val != null && !importsMap.exists(key)) {
				importsMap.set(key, val);
			}
		}

		// Garante tipos fundamentais do Haxe e do sistema
		importsMap.set("Std", Std);
		importsMap.set("Math", Math);
		importsMap.set("StringTools", StringTools);
		importsMap.set("FileSystem", sys.FileSystem);
		importsMap.set("File", sys.io.File);
		importsMap.set("Sys", Sys);
		importsMap.set("ScriptedState", runtime.ScriptedState);
		#end
	}

	/**
	 * MACRO EXPANSIVA: Compila e expõe todas as bibliotecas e classes do ecossistema
	 * do jogo diretamente no ambiente do ScriptGroup sem precisar de arquivos externos.
	 */
	public static macro function initMacroImports():Expr {
		var pairs:Array<Expr> = [];

		// Força a inclusão e análise dos módulos principais do Flixel, OpenFL e Haxe
		var modulesToScan:Array<String> = [
			"flixel.FlxG",
			"flixel.FlxSprite",
			"flixel.FlxState",
			"flixel.FlxSubState",
			"flixel.FlxBasic",
			"flixel.FlxObject",
			"flixel.FlxCamera",
			"flixel.text.FlxText",
			"flixel.ui.FlxButton",
			"flixel.group.FlxSpriteGroup",
			"flixel.group.FlxGroup",
			"flixel.math.FlxMath",
			"flixel.math.FlxPoint",
			"flixel.util.FlxColor",
			"flixel.util.FlxTimer",
			"flixel.tweens.FlxTween",
			"flixel.tweens.FlxEase",
			"flixel.sound.FlxSound",
			"openfl.display.Sprite",
			"openfl.display.BitmapData",
			"openfl.utils.Assets"
		];

		for (mod in modulesToScan) {
			try {
				Context.getModule(mod);
			} catch (e:Dynamic) {}
		}

		// Mapeamento explícito para a árvore de expressão do Haxe
		var classList:Array<Array<String>> = [
			// Flixel Core & Gameplay
			["FlxG", "flixel.FlxG"],
			["FlxSprite", "flixel.FlxSprite"],
			["FlxState", "flixel.FlxState"],
			["FlxSubState", "flixel.FlxSubState"],
			["FlxBasic", "flixel.FlxBasic"],
			["FlxObject", "flixel.FlxObject"],
			["FlxCamera", "flixel.FlxCamera"],
			["FlxGame", "flixel.FlxGame"],
			
			// Flixel UI & Rendering
			["FlxText", "flixel.text.FlxText"],
			["FlxButton", "flixel.ui.FlxButton"],
			["FlxBar", "flixel.ui.FlxBar"],
			["FlxSpriteGroup", "flixel.group.FlxSpriteGroup"],
			["FlxGroup", "flixel.group.FlxGroup"],

			// Flixel Math & Tween
			["FlxMath", "flixel.math.FlxMath"],
			["FlxPoint", "flixel.math.FlxPoint"],
			["FlxColor", "flixel.util.FlxColor"],
			["FlxTimer", "flixel.util.FlxTimer"],
			["FlxTween", "flixel.tweens.FlxTween"],
			["FlxEase", "flixel.tweens.FlxEase"],
			["FlxSound", "flixel.sound.FlxSound"],

			// Display & OpenFL
			["Sprite", "openfl.display.Sprite"],
			["BitmapData", "openfl.display.BitmapData"],
			["Assets", "openfl.utils.Assets"]
		];

		for (item in classList) {
			var alias = item[0];
			var fullPath = item[1];
			var pathExpr = Context.parse(fullPath, Context.currentPos());

			pairs.push(macro m.set($v{alias}, $pathExpr));
		}

		return macro {
			var m = new Map<String, Dynamic>();
			{$b{pairs}};
			m;
		};
	}

	// =========================================================================
	// CONSTRUTOR E GERENCIAMENTO DE SCRIPTS
	// =========================================================================
	public function new() {
		parser = new Parser();
		parser.allowTypes = true;    // Suporte para declaração de tipos e import
		parser.allowJSON = true;     // Suporte à estruturas em formato JSON
		parser.allowMetadata = true; // Suporte a anotações e metadata (@:meta)
	}

	public function addScript(path:String, ?presetVariables:Map<String, Dynamic>):Script {
		if (presetVariables == null) {
			presetVariables = new Map<String, Dynamic>();
		}

		if (FileSystem.exists(path)) {
			var rawCode = File.getContent(path);
			processHeaderDeclarations(rawCode, presetVariables);
		}

		// Adiciona todas as classes do mapa de imports ao escopo local do script
		for (key => val in importsMap) {
			if (!presetVariables.exists(key)) {
				presetVariables.set(key, val);
			}
		}

		var script = new Script(path, presetVariables, parser);
		scripts.push(script);
		return script;
	}

	// =========================================================================
	// PROCESSAMENTO DE PACKAGE E IMPORTS
	// =========================================================================
	private function processHeaderDeclarations(code:String, presetVars:Map<String, Dynamic>):Void {
		var lines = code.split("\n");

		for (line in lines) {
			var trimmed = StringTools.trim(line);

			// 1. Tratamento de Package: Ignora no HScript para não quebrar a compilação
			if (StringTools.startsWith(trimmed, "package") && (trimmed.length == 7 || trimmed.charAt(7) == " " || trimmed.charAt(7) == ";")) {
				continue;
			}

			// 2. Tratamento de Import: Mapeia o caminho e associa a classe no runtime
			if (StringTools.startsWith(trimmed, "import ")) {
				var endIdx = trimmed.indexOf(";");
				if (endIdx == -1) endIdx = trimmed.length;

				var importPath = StringTools.trim(trimmed.substring(7, endIdx));
				var parts = importPath.split(".");
				var className = parts[parts.length - 1];

				// Busca no mapa pré-carregado
				if (importsMap.exists(className)) {
					presetVars.set(className, importsMap.get(className));
					continue;
				}

				// Resolução dinâmica via Reflection caso não esteja pré-mapeado
				var resolvedClass:Dynamic = Type.resolveClass(importPath);
				if (resolvedClass == null) {
					resolvedClass = Type.resolveEnum(importPath);
				}

				if (resolvedClass != null) {
					presetVars.set(className, resolvedClass);
					importsMap.set(className, resolvedClass);
				}
			}
		}
	}

	// =========================================================================
	// EXECUÇÃO E LIFECYCLE
	// =========================================================================
	public function call(funcName:String, ?args:Array<Dynamic>):Void {
		if (args == null) args = [];

		for (script in scripts) {
			if (script != null && script.active) {
				script.callFunction(funcName, args);
			}
		}
	}

	public function setAll(variable:String, value:Dynamic):Void {
		for (script in scripts) {
			if (script != null && script.active) {
				script.set(variable, value);
			}
		}
	}

	public function destroy():Void {
		for (script in scripts) {
			if (script != null) {
				script.active = false;
			}
		}
		scripts = [];
	}
}
