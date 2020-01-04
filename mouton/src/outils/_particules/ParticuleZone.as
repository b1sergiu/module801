package outils._particules {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.getTimer;

public class ParticuleZone extends Bitmap {

	////////////////////////////////////////////////////////////
	//// Variables publiques
	////////////////////////////////////////////////////////////

	public var transformation:ColorTransform = new ColorTransform;
	public var listeParticule:Vector.<Particule> = new Vector.<Particule>();
	public var demandeRendu:Boolean = true;
	public var rectangleZone:Rectangle;

	////////////////////////////////////////////////////////////
	//// Variables privées
	////////////////////////////////////////////////////////////

	private var dureeImage:Number = 0.036;
	private var derniereImage:int = 0;
	private var fonctionMouvement:Function;
	private var fonctionMouvementActive:Boolean;
	private var majAuto:Boolean = true;
	private var tempsZero:int = 0;
	public var modeMonoParticule:Boolean = false;
	public var dernierImageMonoParticule:BitmapData = null;
	public var transformationSpeciale:Boolean = false;

	////////////////////////////////////////////////////////////
	//// Constructeur
	////////////////////////////////////////////////////////////

	public function ParticuleZone(X:int, Y:int, LARGEUR:int, HAUTEUR:int, MOUVEMENT:Function = null, IPS:int = 36) {
		if (MOUVEMENT == null) {
			fonctionMouvementActive = false;
		} else {
			fonctionMouvementActive = true;
			fonctionMouvement = MOUVEMENT;
		}
		//
		dureeImage = IPS / 1000;
		rectangleZone = new Rectangle(0, 0, LARGEUR, HAUTEUR);
		//
		transformation.alphaMultiplier = 0;
		//
		bitmapData = new BitmapData(LARGEUR, HAUTEUR, true, 0);
		x = X;
		y = Y;
	}

	//
	public function renduParticules():void {
		if (demandeRendu) {
			var temps:int = getTimer();
			var tempsEcoule:int = temps - tempsZero;
			var imageEnCours:int = tempsEcoule * dureeImage;
			if (imageEnCours <= derniereImage) {
				return;
			}
			var imageACalculer:int = imageEnCours - derniereImage;
			derniereImage = imageEnCours;
			//
			if (transformationSpeciale) {
				bitmapData.colorTransform(bitmapData.rect, transformation);
			} else {
				if (!modeMonoParticule) {
					bitmapData.fillRect(rectangleZone, 0);
				}
			}
			demandeRendu = false;
			//
			var i:int = -1;
			var numParticule:int = listeParticule.length;
			while (++i < numParticule) {
				demandeRendu = true;
				//
				var particule:Particule = listeParticule[i];
				//
				if (particule.demandeDestruction) {
					listeParticule.splice(i, 1);
					i--;
					numParticule--;
					continue;
				}
				//
				if (particule.tempsMort) {
					if (particule.tempsMort > temps) {
						continue;
					}
				}
				//
				if (particule.fonctionMouvement != null) {
					particule.fonctionMouvement(particule);
				} else if (fonctionMouvementActive) {
					fonctionMouvement(particule);
				}
				//
				if (particule.lectureEnCours) {
					var imageParticule:ParticuleImage = particule.listeImage[particule.imageEnCours];
					//
					if (!imageParticule.dejaRendu) {
						imageParticule.renduImage();
					}
					//
					particule.imageParticuleEnCours = imageParticule;
					particule.imageBrute = imageParticule.imageBrute;
					//
					if (particule.activerControleIPS) {
						particule.imageTotaleControleIPS += imageACalculer;
						if (particule.imageTotaleControleIPS % particule.dureeImageControleIPS == 0) {
							particule.imageEnCours++;
						}
					} else {
						particule.imageEnCours += imageACalculer;
					}
					//
					if (particule.numImageStopAuto && particule.imageEnCours >= particule.numImageStopAuto) {
						particule.imageEnCours = particule.numImageStopAuto;
						particule.lectureEnCours = false;
					}
					//
					if (particule.imageEnCours >= particule.nombreImageTotale) {
						particule.nombreBoucle++;
						if (particule.particuleEnBoucle) {
							particule.imageEnCours = particule.imageEnCours % particule.nombreImageTotale;
						} else {
							particule.demandeDestruction = true;
							particule.lectureEnCours = false;
						}
					}
					//
					if (particule.executionCodeAutomatique) {
						if (particule.imageEnCours >= particule.imageExecutionCodeAuto && particule.derniereBoucleExecution != particule.nombreBoucle) {
							particule.derniereBoucleExecution = particule.nombreBoucle;
							if (particule.fonctionCodeAuto != null) {
								if (particule.paramCodeAuto != null) {
									particule.fonctionCodeAuto(particule.paramCodeAuto);
								} else {
									particule.fonctionCodeAuto();
								}
							}
						}
					}
					//
					//					if (particule.numImageStopAuto && particule.imageEnCours >= particule.numImageStopAuto) {
					//						particule.imageEnCours = particule.numImageStopAuto - 1;
					//						particule.numImageStopAuto = 0;
					//						particule.lectureEnCours = false;
					//					}
				}
				if (particule.affichage && particule.imageBrute) {
					if (modeMonoParticule) {
						if (dernierImageMonoParticule == particule.imageBrute) {
							return;
						}
						dernierImageMonoParticule = particule.imageBrute;
						bitmapData.fillRect(rectangleZone, 0);
						bitmapData.copyPixels(particule.imageBrute, particule.imageBrute.rect, new Point(particule.imageParticuleEnCours.posBaseX + particule.posX, particule.imageParticuleEnCours.posBaseY + particule.posY), null, null, true);
					} else {
						bitmapData.copyPixels(particule.imageBrute, particule.imageBrute.rect, new Point(particule.imageParticuleEnCours.posBaseX + particule.posX, particule.imageParticuleEnCours.posBaseY + particule.posY), null, null, true);
					}
				}
			}
		} else {
			tempsZero = getTimer();
			derniereImage = 0;
		}
	}

	//
	public function toutEffacer():void {
		if (listeParticule.length) {
			bitmapData.fillRect(rectangleZone, 0);
			listeParticule = new Vector.<Particule>();
		}
	}

	public function desactiverMajAuto(OUI:Boolean):void {
		if (OUI && majAuto) {
			majAuto = false;
			bitmapData.lock();
		} else if (!OUI && !majAuto) {
			majAuto = true;
			bitmapData.unlock();
		}

	}
}
}