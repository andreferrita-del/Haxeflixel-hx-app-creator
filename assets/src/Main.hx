package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import sys.FileSystem;

// Variáveis globais do script
var titleText:FlxText;
var subtitleText:FlxText;
var boxSprite:FlxSprite;

function create() {
	// Configura o fundo
	FlxG.cameras.bgColor = 0xFF181818;

	// Texto de Título
	titleText = new FlxText(0, FlxG.height * 0.25, FlxG.width, "Runtime Engine Loaded!", 40);
	titleText.alignment = "center";
	titleText.color = FlxColor.CYAN;
	add(titleText);

	// Texto Subtítulo / Instruções
	subtitleText = new FlxText(0, titleText.y + 60, FlxG.width, "Pressione ESPAÇO para efeito | R para recarregar", 18);
	subtitleText.alignment = "center";
	subtitleText.color = FlxColor.GRAY;
	add(subtitleText);

	// Criando um objeto visual na tela
	boxSprite = new FlxSprite(FlxG.width / 2 - 50, FlxG.height / 2);
	boxSprite.makeGraphic(100, 100, FlxColor.PURPLE);
	add(boxSprite);

	// Animação de Entrada
	FlxTween.tween(boxSprite.scale, {x: 1.2, y: 1.2}, 1, {ease: FlxEase.quadInOut, type: 4});
}

function update(elapsed:Float) {
	// Rotação do objeto
	if (boxSprite != null) {
		boxSprite.angle += 90 * elapsed;
	}

	// Exemplo de Input: Barra de Espaço
	if (FlxG.keys.justPressed.SPACE) {
		FlxG.camera.flash(FlxColor.WHITE, 0.3);
		boxSprite.color = FlxColor.fromRGB(
			Std.random(255), 
			Std.random(255), 
			Std.random(255)
		);
	}

	// Exemplo de Input: Tecla R (Reiniciar Estado)
	if (FlxG.keys.justPressed.R) {
		FlxG.resetState();
	}
}

function onDestroy() {
	// Limpeza de recursos ao fechar o estado
	titleText = null;
	subtitleText = null;
	boxSprite = null;
}
