package outils._particules {

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.getTimer;

public class Particule {

	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	public var particuleZeroBase:ParticuleZero;
	public var demandeDestruction:Boolean = false;
	public var imageBrute:BitmapData;
	public var imageParticuleEnCours:ParticuleImage;
	public var listeImage:Vector.<ParticuleImage>;
	public var nombreImageTotale:int;
	public var imageEnCours:int;
	public var particuleEnBoucle:Boolean;
	public var fonctionMouvement:Function;
	public var lectureEnCours:Boolean;
	public var affichage:Boolean = true;
	public var nombreBoucle:int = 0;
	public var tempsLimite:int = 0;
	public var posX:Number = 0;
	public var posY:Number = 0;
	public var vitesseX:Number = 0;
	public var vitesseY:Number = 0;
	public var accelerationX:Number = 0;
	public var accelerationY:Number = 0;
	public var tempsMort:int = 0;

	// Controle du fps
	public var activerControleIPS:Boolean = false;
	public var dureeImageControleIPS:int = 1;
	public var imageTotaleControleIPS:int = 0;

	// Stop automatique
	public var numImageStopAuto:int = 0;

	// Execution code
	public var executionCodeAutomatique:Boolean = false;
	public var imageExecutionCodeAuto:int;
	public var fonctionCodeAuto:Function;
	public var paramCodeAuto:Object;
	public var derniereBoucleExecution:int = -1;

	////////////////////////////////////////////////////////////
	//// Constructeur
	////////////////////////////////////////////////////////////

	public function Particule(PARTICULE:ParticuleZero, BOUCLE:Boolean = true) {
		if (PARTICULE == null) {
			affichage = false;
			lectureEnCours = false;
		} else {
			initialisation(PARTICULE, BOUCLE);
		}
	}

	////////////////////////////////////////////////////////////
	//// Méthodes publique
	////////////////////////////////////////////////////////////

	public function initialisation(PARTICULE:ParticuleZero, BOUCLE:Boolean = true):void {
		affichage = true;
		lectureEnCours = true;
		particuleZeroBase = PARTICULE;
		particuleEnBoucle = BOUCLE;
		listeImage = PARTICULE.listeImage;
		nombreImageTotale = listeImage.length;
		imageEnCours = 0;
	}

	public function codeAutomatique(IMAGE:int, FONCTION:Function, PARAM:Object = null):void {
		executionCodeAutomatique = true;
		imageExecutionCodeAuto = IMAGE;
		fonctionCodeAuto = FONCTION;
		paramCodeAuto = PARAM;
		derniereBoucleExecution = -1;
	}

	public function lectureDepuisImage(NUM:int, STOP:int = 0, FONCTION:Function = null, PARAM:Object = null):void {
		if (!affichage) {
			return;
		}
		nombreBoucle = 0;
		imageTotaleControleIPS = 0;
		derniereBoucleExecution = -1;
		numImageStopAuto = STOP;
		if (FONCTION != null) {
			codeAutomatique(STOP, FONCTION, PARAM);
		}
		lectureEnCours = true;
		if (NUM < 0) {
			imageEnCours = 0;
		} else if (NUM >= nombreImageTotale) {
			imageEnCours = nombreImageTotale - 1;
		} else {
			imageEnCours = NUM;
		}
		imageParticuleEnCours = listeImage[imageEnCours];
		if (!imageParticuleEnCours.dejaRendu) {
			imageParticuleEnCours.renduImage();
		}
		imageBrute = imageParticuleEnCours.imageBrute;
	}

}
}