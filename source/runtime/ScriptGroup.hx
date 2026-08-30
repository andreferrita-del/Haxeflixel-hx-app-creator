package runtime;

import hscript.Parser;
import sys.FileSystem;
import sys.io.File;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class ScriptGroup {
	public var scripts:Array<Script> = [];
	public var parser:Parser;

	public static var importsMap:Map<String, Dynamic> = new Map<String, Dynamic>();

	// Mapeia as classes essenciais e utilitários compilados no projeto
	static function __init__() {
		#if !macro
		// Registra explicitamente os módulos padrão do Haxe e bibliotecas essenciais
		importsMap.set("Std", Std);
		importsMap.set("Math", Math);
		importsMap.set("StringTools", StringTools);
		importsMap.set("FileSystem", sys.FileSystem);
		importsMap.set("File", sys.io.File);
		importsMap.set("Sys", Sys);
		importsMap.set("Type", Type);
		importsMap.set("Reflect", Reflect);
		#end
	}

	public function new() {
		parser = new Parser();
		parser.allowTypes = true;    // Permite declarações de tipo (ex: var a:Int)
		parser.allowJSON = true;     // Permite sintaxe estendida de JSON
		parser.allowMetadata = true; // Permite metadados (@:meta)
	}

	public function addScript(path:String, ?presetVariables:Map<String, Dynamic>):Script {
		if (presetVariables == null) {
			presetVariables = new Map<String, Dynamic>();
		}

		for (key => val in importsMap) {
			if (!presetVariables.exists(key)) {
				presetVariables.set(key, val);
			}
		}

		if (FileSystem.exists(path)) {
			var rawCode = File.getContent(path);
			processHeaderDeclarations(rawCode, presetVariables);
		}

		var script = new Script(path, presetVariables, parser);
		scripts.push(script);
		return script;
	}

	// Filtra 'package' para não quebrar o HScript e mapeia os 'import' dinamicamente
	private function processHeaderDeclarations(code:String, presetVars:Map<String, Dynamic>):Void {
		var lines = code.split("\n");

		for (line in lines) {
			var trimmed = StringTools.trim(line);

			// Suporte a package: Ignora no interpretador para evitar erros de sintaxe
			if (StringTools.startsWith(trimmed, "package") && (trimmed.length == 7 || trimmed.charAt(7) == " " || trimmed.charAt(7) == ";")) {
				continue;
			}

			// Suporte a import: Associa a classe chamada à variável no ambiente local
			if (StringTools.startsWith(trimmed, "import ")) {
				var endIdx = trimmed.indexOf(";");
				if (endIdx == -1) endIdx = trimmed.length;

				var importPath = StringTools.trim(trimmed.substring(7, endIdx));
				var parts = importPath.split(".");
				var className = parts[parts.length - 1];

				if (importsMap.exists(className)) {
					presetVars.set(className, importsMap.get(className));
				}
			}
		}
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Void {
		var params:Array<Dynamic> = (args == null) ? [] : args;

		for (script in scripts) {
			if (script != null && script.active) {
				// Chama a função passando a lista de argumentos sem excesso de parâmetros
				script.callFunction(funcName, params);
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
