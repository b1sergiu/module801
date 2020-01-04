/**
 * Auteur : Tigrou
 * Date : 18/04/2015 - 12:35
 */
package outils {

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;

public class Outils {

	////////////////////////////////////////////////////////////
	//// Constantes
	////////////////////////////////////////////////////////////

	static private const couleurLumiere:ColorTransform = new ColorTransform(1.3, 1.3, 1.3);
	static private const couleurNormal:ColorTransform = new ColorTransform();
	
	////////////////////////////////////////////////////////////
	//// Méthodes
	////////////////////////////////////////////////////////////
	
	static public function lumiereSouris(CIBLE:Sprite, OUI:Boolean = true):void {
		if (OUI) {
			CIBLE.addEventListener(MouseEvent.MOUSE_OVER, lumiereSouris1);
			CIBLE.addEventListener(MouseEvent.MOUSE_OUT, lumiereSouris2);
		} else {
			CIBLE.removeEventListener(MouseEvent.MOUSE_OVER, lumiereSouris1);
			CIBLE.removeEventListener(MouseEvent.MOUSE_OUT, lumiereSouris2);
			CIBLE.transform.colorTransform = couleurNormal;
		}
		CIBLE.useHandCursor = OUI;
		CIBLE.buttonMode = OUI;
	}

	static private function lumiereSouris1(E:MouseEvent):void {
		var cible:Sprite = E.currentTarget as Sprite;
		cible.transform.colorTransform = couleurLumiere;
	}

	static private function lumiereSouris2(E:MouseEvent):void {
		var cible:Sprite = E.currentTarget as Sprite;
		cible.transform.colorTransform = couleurNormal;
	}
	
}
}
