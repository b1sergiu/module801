package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;

import outils.Outils;
import outils._particules.Particule;
import outils._particules.ParticuleImage;
import outils._particules.ParticuleZero;
import outils._particules.ParticuleZone;

public class MondeMouton extends Sprite {

	////////////////////////////////////////////////////////////
	//// Constantes
	////////////////////////////////////////////////////////////

	static private const VALEUR_GRAVITE:Number = 400;
	static private var particuleMorceau:ParticuleZero;
	static public var mondeEnCours:MondeMouton;
	static public var anomalieTemps:Boolean = false;

	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	private var clipMonde:Sprite;
	private var tempsZeroPartie:int;
	private var tempsCalculePartie:int;
	private var listePiegesActifs:Vector.<PiegeMouton> = new Vector.<PiegeMouton>();
	private var tremblementEnCours:Boolean = false;
	private var finTremblement:int;
	private var puissanceTremblement:int;
	private var prochaineMajCurseur:int;
	private var curseur:Sprite;
	private var positionCurseurCible:Point = new Point();
	private var positionCurseurDepart:Point = new Point();
	private var tempsDepartCurseur:int = 0;
	private var intervalMajCurseur:int = 100;
	private var ligneVictoire:int = 590 + Math.random() * 40;
	private var champsInfo:TextField;
	private var champsTuto:TextField;
	public var tempsBaseRestant:int;
	public var tempsReceptionTempsRestant:int;
	private var prochaineSeconde:int;
	private var dernierePosSourisX:int = -1;
	private var dernierePosSourisY:int = -1;
	private var tempsZero:int = getTimer();

	// Couches
	private var couchePiege:Sprite;
	private var coucheJoueurs:Sprite;
	private var imageMur:BitmapData;
	private var imageSol:BitmapData;
	private var zoneParticule:ParticuleZone;

	////////////////////////////////////////////////////////////
	//// Constructor
	////////////////////////////////////////////////////////////

	public function MondeMouton(id:int) {
		mondeEnCours = this;
		clipMonde = Mouton.recupClip("$Monde_" + id);
		addEventListener(Event.ENTER_FRAME, boucle);
		tempsZeroPartie = getTimer();
		//
		imageMur = new BitmapData(640, 300, true, 0xFF999999);
		imageSol = new BitmapData(640, 180, true, 0xFF666666);
		imageSol.fillRect(new Rectangle(0, 0, 640, 2), 0);
		var conteneurImageMur:Bitmap = new Bitmap(imageMur);
		addChild(conteneurImageMur);
		var conteneurImageSol:Bitmap = new Bitmap(imageSol);
		conteneurImageSol.y = 300;
		//
		coucheJoueurs = new Sprite();
		coucheJoueurs.mouseChildren = false;
		coucheJoueurs.mouseEnabled = false;
		addChild(coucheJoueurs);
		//
		couchePiege = new Sprite();
		couchePiege.mouseChildren = false;
		couchePiege.mouseEnabled = false;
		addChild(couchePiege);
		//
		addChild(conteneurImageSol);
		addChild(clipMonde);
		//
		champsInfo = new TextField();
		champsInfo.defaultTextFormat = new TextFormat("Verdana", 12, 0x111111);
		champsInfo.x = Mouton.instance.clipListeJoueur.x + Mouton.instance.clipListeJoueur.width;
		champsInfo.y = 340;
		champsInfo.width = 640 - champsInfo.x;
		champsInfo.height = 50;
		addChild(champsInfo);
		//
		champsTuto = new TextField();
		champsTuto.defaultTextFormat = new TextFormat("Verdana", 12, 0x222222);
		champsTuto.wordWrap = true;
		champsTuto.multiline = true;
		champsTuto.x = champsInfo.x;
		champsTuto.y = champsInfo.y + champsInfo.height;
		champsTuto.width = 640 - champsTuto.x;
		champsTuto.height = 480 - champsTuto.y;
		champsTuto.text = "Keyboard arrow to move. Get the paddock if you are a sheep or kill every sheep if you are the shepherd! Press space to protect your sheep!";
		addChild(champsTuto);
		//
		curseur = Mouton.recupClip("$CurseurBerger");
		curseur.mouseChildren = false;
		curseur.mouseEnabled = false;
		curseur.cacheAsBitmap = true;
		addChild(curseur);
		//
		zoneParticule = new ParticuleZone(0, 0, 640, 480, mouvementParticule, 60);
		addChild(zoneParticule);
	}

	////////////////////////////////////////////////////////////
	//// Methods
	////////////////////////////////////////////////////////////

	public function majTexteInfo():void {
		var tempsRestant:int = (tempsBaseRestant - (getTimer() - tempsReceptionTempsRestant)) / 1000;
		champsInfo.text = "Time left: " + tempsRestant + " s\nShepherd: " + (Mouton.instance.bergerEnCours ? Mouton.instance.bergerEnCours.nomJoueur : "") + "\nSheep: " + JoueurMouton.listeJoueurs.length + " / Room: " + Mouton.nomSalon;
	}

	public function initialisationPiegeBerger(POSITION:int, ID_PIEGE:int):void {
		var piege:PiegeMouton = new PiegeMouton(ID_PIEGE, POSITION);
		piege.clipPiege.gotoAndStop(1);
		piege.name = String(ID_PIEGE);
		couchePiege.addChild(piege);
		couchePiege.mouseChildren = true;
		Outils.lumiereSouris(piege);
		piege.addEventListener(MouseEvent.MOUSE_DOWN, cliquePiege);
	}

	public function activerPiege(ID_PIEGE:int, POSITION:int):void {
		var piege:PiegeMouton = new PiegeMouton(ID_PIEGE, POSITION);
		piege.clipPiege.gotoAndStop(2);
		piege.tempsActivation = getTimer();
		couchePiege.addChild(piege);
		listePiegesActifs.push(piege);
		piege.mouseChildren = false;
		piege.mouseEnabled = false;
	}

	public function majPositionCurseur(POX:int, POY:int):void {
		positionCurseurCible.x = POX;
		positionCurseurCible.y = POY;
		positionCurseurDepart.x = curseur.x;
		positionCurseurDepart.y = curseur.y;
		tempsDepartCurseur = getTimer();
	}

	public function boucle(e:Event):void {
		if (!parent) {
			removeEventListener(Event.ENTER_FRAME, boucle);
		}
		zoneParticule.renduParticules();
		//
		var joueurPrincipal:JoueurMouton = JoueurMouton.joueurPrincipal;
		var temps:int = getTimer();
		var tempsEcoule:int = temps - tempsZeroPartie;
		var tempsImage:Number = (tempsEcoule - tempsCalculePartie) / 1000;
		if (joueurPrincipal.x > 200 && tempsImage > 0.5) {
			joueurPrincipal.mort(2);
		} else if (tempsImage > 0.2) {
			tempsImage = 0.2;
		}
		tempsCalculePartie = tempsEcoule;
		//
		if (temps > prochaineSeconde) {
			prochaineSeconde = temps + 1000;
			majTexteInfo();
			if (!joueurPrincipal.estMort) {
				joueurPrincipal.synchronisationJoueurPrincipal();
			}
		}
		//
		if (anomalieTemps) {
			joueurPrincipal.mort(0);
		}
		// Boucle curseur
		if (tempsDepartCurseur) {
			var tempsEcouleCurseur:int = temps - tempsDepartCurseur;
			var pourcentage:Number = tempsEcouleCurseur / intervalMajCurseur;
			if (pourcentage >= 1) {
				tempsDepartCurseur = 0;
				curseur.x = positionCurseurCible.x;
				curseur.y = positionCurseurCible.y;
			} else {
				curseur.x = positionCurseurDepart.x + (positionCurseurCible.x - positionCurseurDepart.x) * pourcentage;
				curseur.y = positionCurseurDepart.y + (positionCurseurCible.y - positionCurseurDepart.y) * pourcentage;
			}
		}
		//
		if (temps > prochaineMajCurseur && Mouton.instance.bergerEnCours && Mouton.instance.bergerEnCours.estJoueurPrincipal) {
			if (int(mouseX) != dernierePosSourisX && int(mouseY) != dernierePosSourisY) {
				dernierePosSourisX = int(mouseX);
				dernierePosSourisY = int(mouseY);
				prochaineMajCurseur = temps + intervalMajCurseur;
				Mouton.instance.module801.sendToServer(2, int(mouseX), int(mouseY));
			}
		}
		//
		if (tremblementEnCours) {
			if (temps > finTremblement) {
				tremblementEnCours = false;
				x = 0;
				y = 0;
			} else {
				x = (Math.random() * puissanceTremblement) - (puissanceTremblement / 2);
				y = (Math.random() * puissanceTremblement) - (puissanceTremblement / 2);
			}
		}
		// Physique déplacement
		var i:int = -1;
		var num:int = JoueurMouton.listeJoueurs.length;
		while (++i < num) {
			var mouton:JoueurMouton = JoueurMouton.listeJoueurs[i];
			mouton.zoneAnim.renduParticules();
			if (mouton.listeTexteDoge.length) {
				var texte:TexteDoge = mouton.listeTexteDoge[0];
				if (temps > texte.finTexte) {
					mouton.listeTexteDoge.shift();
					if (texte.parent) {
						texte.parent.removeChild(texte);
					}
				}
			}
			if (mouton.protectionEnCours && temps > mouton.finProtection) {
				mouton.retirerProtection();
			}
			// Droite
			if (!mouton.estMort) {
				if (mouton.droiteEnCours) {
					mouton.x += tempsImage * mouton.vitesseDeplacement;
					mouton.defVersLaDroite(true);
				} else if (mouton.gaucheEnCours) {
					mouton.x -= tempsImage * mouton.vitesseDeplacement;
					mouton.defVersLaDroite(false);
				}
			}
			// Gravité
			mouton.vitesseY += VALEUR_GRAVITE * tempsImage + mouton.accelerationY * tempsImage;
			mouton.y += mouton.vitesseY * tempsImage;
			mouton.x += mouton.vitesseX * tempsImage;
			if (mouton.x < 0) {
				mouton.x = 0;
				mouton.vitesseX = -mouton.vitesseX / 4;
			} else if (mouton.x > 640) {
				mouton.x = 640;
				mouton.vitesseX = -mouton.vitesseX / 4;
			}
			if (mouton.y > 300) {
				mouton.y = 300;
				mouton.vitesseY = -mouton.vitesseY / 4;
				mouton.vitesseX = mouton.vitesseX / 2;
				if (mouton.vitesseX < 0.01 && mouton.vitesseX > -0.01) {
					mouton.vitesseX = 0;
				}
				if (mouton.vitesseY > -0.001) {
					mouton.vitesseY = 0;
				}
				mouton.peutSauter = true;
			}
		}
		var coeurJoueurX:int = JoueurMouton.joueurPrincipal.x;
		var coeurJoueurY:int = JoueurMouton.joueurPrincipal.y - 20;
		// Victoire
		if (!joueurPrincipal.estMort && coeurJoueurX >= ligneVictoire) {
			joueurPrincipal.mort(44);
		}
		// Piege
		i = -1;
		num = listePiegesActifs.length;
		while (++i < num) {
			var piege:PiegeMouton = listePiegesActifs[i];
			var tempsEcoulePiege:Number = (temps - piege.tempsActivation) / 1000;
			var imageEnCours:int = tempsEcoulePiege * 60 + 2;
			if (imageEnCours >= piege.clipPiege.totalFrames) {
				if (piege.parent) {
					piege.parent.removeChild(piege);
				}
				listePiegesActifs.splice(i, 1);
				i--;
				num--;
				continue;
			}
			piege.clipPiege.gotoAndStop(imageEnCours);
			var etiquette:String = piege.clipPiege.currentLabel;
			if (etiquette) {
				var infoEtiquette:Array = etiquette.split(",");
				var codeEtiquette:int = infoEtiquette[1];
				if (codeEtiquette != piege.effetEtiquetteEnCours) {
					piege.effetEtiquetteEnCours = codeEtiquette;
					if (infoEtiquette[0] == "T") {
						tremblementEcran(infoEtiquette[2], infoEtiquette[3]);
					}
				}
			}
			if (!joueurPrincipal.estMort && temps > joueurPrincipal.finProtection) {
				// On regarde si le piege touche le joueur principal
				if (piege.hitTestPoint(coeurJoueurX, coeurJoueurY, true)) {
					joueurPrincipal.mort(piege.identifiantPiege);
				}
			}
		}
	}

	public function ajouterJoueur(JOUEUR:JoueurMouton):void {
		JOUEUR.animation(0);
		JOUEUR.droiteEnCours = false;
		JOUEUR.gaucheEnCours = false;
		JOUEUR.peutSauter = true;
		JOUEUR.peutSeProteger = true;
		JOUEUR.retirerProtection();
		coucheJoueurs.addChild(JOUEUR);
		if (JoueurMouton.joueurPrincipal && !JoueurMouton.joueurPrincipal.estMort) {
			coucheJoueurs.addChild(JoueurMouton.joueurPrincipal);
		}
	}

	public function effetMortMouton(JOUEUR:JoueurMouton, CODE_PIEGE:int):void {
		if (CODE_PIEGE == 44 || CODE_PIEGE == 33) {
			return;
		}
		var posX:int = JOUEUR.x;
		var posY:int = JOUEUR.y - 20;
		var temps:int = getTimer();
		if (!particuleMorceau) {
			particuleMorceau = new ParticuleZero(Mouton.recupClip("$MorceauMouton"));
		}
		var i:int = -1;
		while (++i < 4) {
			var morceau:Particule = new Particule(particuleMorceau);
			morceau.tempsLimite = temps + Math.random() * 3000;
			zoneParticule.listeParticule.push(morceau);
			zoneParticule.demandeRendu = true;
			morceau.posX = posX;
			morceau.posY = posY;
			morceau.vitesseX = Math.random() * 10 - 5;
			morceau.vitesseY = -(Math.random() * 10);
			morceau.accelerationY = 0.2;
		}
		ajouterTache(posX, posY, true);
		ajouterTache(posX, posY, false);
		// Pique
		if (CODE_PIEGE == 20 || CODE_PIEGE == 21) {
			JOUEUR.vitesseY -= 200 + Math.random() * 200;
			JOUEUR.vitesseX = Math.random() * 100 - 50;
		} else if (CODE_PIEGE == 1) {
			JOUEUR.vitesseY -= 200 + Math.random() * 200;
			JOUEUR.vitesseX = -Math.random() * 1000;
		}
	}

	public function tremblementEcran(PUISSANCE:int = 5, DUREE:int = 150):void {
		var temps:int = getTimer();
		if (temps < finTremblement && PUISSANCE < puissanceTremblement) {
			return;
		}
		finTremblement = temps + DUREE;
		puissanceTremblement = PUISSANCE;
		tremblementEnCours = true;
	}

	////////////////////////////////////////////////////////////
	//// Événements
	////////////////////////////////////////////////////////////

	private function cliquePiege(EVE:MouseEvent):void {
		var piege:PiegeMouton = EVE.currentTarget as PiegeMouton;
		if (piege.parent) {
			piege.parent.removeChild(piege);
		}
		Mouton.instance.module801.sendToServer(7, Mouton.instance.codePartieEnCours, piege.identifiantPiege, piege.positionPiege);
		//		activerPiege(piege.identifiantPiege, piege.positionPiege);
	}


	private function mouvementParticule(particule:Particule):void {
		particule.vitesseX += particule.accelerationX;
		particule.posX += particule.vitesseX;
		//
		particule.vitesseY += particule.accelerationY;
		particule.posY += particule.vitesseY;
		if (particule.posY > 300) {
			particule.posY = 300;
			particule.vitesseY = -particule.vitesseY / 2;
			particule.vitesseX = particule.vitesseX / 2;
			if (particule.vitesseY < -1) {
				ajouterTache(particule.posX, particule.posY, false);
			} else if (particule.vitesseY > -0.001) {
				particule.vitesseY = 0;
			}
		}
		//
		if (particule.tempsLimite) {
			if (getTimer() > particule.tempsLimite) {
				particule.demandeDestruction = true;
				if (particule.posY < 290) {
					ajouterTache(particule.posX, particule.posY, true);
				}
			}
		}
	}

	private function ajouterTache(POX:int, POY:int, MUR:Boolean):void {
		var imageCible:ParticuleImage;
		if (MUR) {
			imageCible = Mouton.listeTacheSangMur.listeImage[int(Math.random() * Mouton.listeTacheSangMur.nombreImages)];
			imageMur.copyPixels(imageCible.imageBrute, imageCible.imageBrute.rect, new Point(POX + imageCible.posBaseX, POY + imageCible.posBaseY), null, null, true);
		} else {
			imageCible = Mouton.listeTacheSangSol.listeImage[int(Math.random() * Mouton.listeTacheSangSol.nombreImages)];
			imageSol.copyPixels(imageCible.imageBrute, imageCible.imageBrute.rect, new Point(POX + imageCible.posBaseX, -2), null, null, true);
		}
	}

}
}
