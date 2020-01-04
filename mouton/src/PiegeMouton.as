/**
 * Auteur : Tigrou
 * Date : 18/04/2015 - 12:42
 */
package {

import flash.display.MovieClip;
import flash.display.Sprite;

public class PiegeMouton extends Sprite {
	
	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	public var identifiantPiege:int;
	public var positionPiege:int;
	public var clipPiege:MovieClip;
	public var tempsActivation:int;
	public var effetEtiquetteEnCours:int = -1;

	////////////////////////////////////////////////////////////
	//// Constructeur
	////////////////////////////////////////////////////////////
	
	public function PiegeMouton(ID_PIEGE:int, POSITION:int) {
		identifiantPiege = ID_PIEGE;
		positionPiege = POSITION;
		clipPiege = Mouton.recupClip("$Piege_" + ID_PIEGE);
		if (POSITION < 4) {
			x = 150 + POSITION * 110;
			y = 0;
		} else {
			x = 150 + (POSITION - 4) * 110;
			y = 300;
		}
		addChild(clipPiege);
	}
	
}
}
