package outils._particules {

import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Rectangle;

public class ParticuleImage {

	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	public var imageBrute:BitmapData;
	public var posBaseX:int = 0;
	public var posBaseY:int = 0;
	public var largeurImage:int;
	public var hauteurImage:int;
	public var dejaRendu:Boolean = false;
	public var clipCible:MovieClip;
	public var imageCible:int;
	public var clipConteneur:Sprite;

	////////////////////////////////////////////////////////////
	//// Constructeur
	////////////////////////////////////////////////////////////

	public function ParticuleImage(OPTIMISATION:Boolean = false) {
		dejaRendu = !OPTIMISATION;
	}

	////////////////////////////////////////////////////////////
	//// Méthodes
	////////////////////////////////////////////////////////////

	public function renduImage():void {
		dejaRendu = true;
		clipConteneur = new Sprite();
		clipConteneur.addChild(clipCible);
		clipCible.gotoAndStop(imageCible);
		//
		var zoneCible:Rectangle = clipCible.getRect(clipCible);
		var etirement:Number = clipCible.scaleX;
		if (etirement > 1) {
			largeurImage = Math.ceil(zoneCible.width * etirement) + 4;
			hauteurImage = Math.ceil(zoneCible.height * etirement) + 4;
			posBaseX = Math.round(zoneCible.x * etirement);
			posBaseY = Math.round(zoneCible.y * etirement);
		} else {
			largeurImage = Math.ceil(zoneCible.width) + 4;
			hauteurImage = Math.ceil(zoneCible.height) + 4;
			posBaseX = Math.round(zoneCible.x);
			posBaseY = Math.round(zoneCible.y);
		}
		//
		clipCible.x = 2 - posBaseX;
		clipCible.y = 2 - posBaseY;
		imageBrute = new BitmapData(largeurImage, hauteurImage, true, 0);
		imageBrute.draw(clipConteneur);
		clipConteneur = null;
		clipCible = null;
	}

	public function resetImage(CLIP:MovieClip):void {
		dejaRendu = false;
		clipCible = CLIP;
		clipConteneur = new Sprite();
	}
}
}