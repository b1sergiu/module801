/**
 * Auteur : Tigrou
 * Date : 19/04/2015 - 15:52
 */
package {

import flash.filters.GlowFilter;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.getTimer;

public class TexteDoge extends TextField {

	////////////////////////////////////////////////////////////
	//// Constantes
	////////////////////////////////////////////////////////////

	static private const filtreTexte:Array = new Array(new GlowFilter(0, 1, 2, 2, 4));
	
	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	public var finTexte:int = getTimer() + 3000;
	
	////////////////////////////////////////////////////////////
	//// Constructeur
	////////////////////////////////////////////////////////////
	
	public function TexteDoge(MESSAGE:String) {
		var couleur:int = ((Math.random() * 0x7F + 0x7F) << 16) | ((Math.random() * 0x7F + 0x7F) << 8) | (Math.random() * 0x7F + 0x7F);
		defaultTextFormat = new TextFormat("Verdana", 11, couleur, true);
		autoSize = TextFieldAutoSize.LEFT;
		height = 18;
		mouseEnabled = false;
		multiline = false;
		wordWrap = false;
		text = MESSAGE;
		filters = filtreTexte;
	}
	
}
}
