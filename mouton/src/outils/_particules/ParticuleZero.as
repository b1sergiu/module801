package outils._particules {

import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.utils.getTimer;

public class ParticuleZero {

	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	public var Largeur:int;
	public var Hauteur:int;
	public var zoneImage:Rectangle;
	public var listeImage:Vector.<ParticuleImage>;
	public var nombreImages:int;
	public var derniereUtilisation:int = getTimer();

	////////////////////////////////////////////////////////////
	//// Constantes
	////////////////////////////////////////////////////////////

	public function ParticuleZero(CLIP:MovieClip = null, OPTIMISATION:Boolean = false, MODULO:int = 0) {
		if (!CLIP) {
			return;
		}
		nombreImages = CLIP.totalFrames;
		listeImage = new Vector.<ParticuleImage>(nombreImages, true);
		//
		var derniereImage:ParticuleImage = null;
		for (var i:int = 0; i < nombreImages; i++) {
			var imageParticule:ParticuleImage;
			if (MODULO == 0 || i % MODULO == 0) {
				imageParticule = new ParticuleImage(OPTIMISATION);
				derniereImage = imageParticule;
				imageParticule.clipCible = CLIP;
				imageParticule.imageCible = i + 1;
				listeImage[i] = imageParticule;
				if (!OPTIMISATION) {
					imageParticule.renduImage();
				}
			} else {
				imageParticule = derniereImage;
			}
			listeImage[i] = imageParticule;
		}
	}
}
}