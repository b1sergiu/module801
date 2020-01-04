package {

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import outils.ClipJoueurListe;

import outils._particules.Particule;
import outils._particules.ParticuleZero;
import outils._particules.ParticuleZone;

public class JoueurMouton extends Sprite {

	////////////////////////////////////////////////////////////
	//// Variables statiques
	////////////////////////////////////////////////////////////

	static public var indexJoueurs:Dictionary = new Dictionary();
	static public var listeJoueurs:Vector.<JoueurMouton> = new Vector.<JoueurMouton>();
	static public var joueurPrincipal:JoueurMouton;
	static public var listeAnimMouton:Vector.<ParticuleZero>;

	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	public var nomJoueur:String;
	public var estJoueurPrincipal:Boolean = false;
	public var zoneAnim:ParticuleZone;
	private var particuleMouton:Particule;
	private var listeAnim:Vector.<Particule>;
	private var indexTexteDoge:int = 0;
	public var listeTexteDoge:Vector.<TexteDoge> = new Vector.<TexteDoge>();
	public var clipJoueurListe:ClipJoueurListe;
	private var casque:Sprite;
	public var peutSeProteger:Boolean = false;
	public var protectionEnCours:Boolean = false;
	public var finProtection:int;

	// État
	public var estMort:Boolean = false;

	// Mouvement
	public var droiteEnCours:Boolean = false;
	public var gaucheEnCours:Boolean = false;
	public var vitesseDeplacement:Number = 40;
	public var peutSauter:Boolean = true;
	public var regardeVersLaDroite:Boolean = true;

	public var vitesseX:Number = 0;
	public var accelerationX:Number = 0;
	public var vitesseY:Number = 0;
	public var accelerationY:Number = 0;

	////////////////////////////////////////////////////////////
	//// Constructor
	////////////////////////////////////////////////////////////

	public function JoueurMouton(NOM:String, isMainPlayer:Boolean = false) {
		this.nomJoueur = NOM;
		if (isMainPlayer) {
			joueurPrincipal = this;
			estJoueurPrincipal = true;
		}
		clipJoueurListe = new ClipJoueurListe(NOM);
		//
		var num:int = listeAnimMouton.length;
		listeAnim = new Vector.<Particule>(num, true);
		var i:int = -1;
		while (++i < num) {
			var anim:Particule = new Particule(listeAnimMouton[i]);
			anim.posX = 48;
			anim.posY = 48;
			listeAnim[i] = anim;
			//
			if (i == 3 || i == 5 || i == 6 || i == 7) {
				anim.particuleEnBoucle = false;
			}
		}
		//
		zoneAnim = new ParticuleZone(-50, -50, 100, 60, null, 60);
		zoneAnim.modeMonoParticule = true;
		zoneAnim.listeParticule.push(listeAnim[0]);
		zoneAnim.demandeRendu = true;
		addChild(zoneAnim);
		//
		var clipNom:MovieClip = Mouton.recupClip("$ClipNom");
		if (estJoueurPrincipal) {
			clipNom.y = -65;
			TextField(clipNom.texte).textColor = 0;
		} else {
			clipNom.y = -45;
		}
		if (NOM.charAt(0) == "*") {
			TextField(clipNom.texte).text = NOM.substr(1);
		} else {
			TextField(clipNom.texte).text = NOM;
		}
		if (estJoueurPrincipal) {
			TextField(clipNom.texte).htmlText = "<b>" + TextField(clipNom.texte).text
		}
		addChild(clipNom);
		clipNom.cacheAsBitmap = true;
		//
		//		var playerTextName:TextField = new TextField();
		//		var format:TextFormat = new TextFormat("Verdana", 12, isMainPlayer ? 0 : 0x4F4F4F);
		//		format.align = TextFormatAlign.CENTER;
		//		playerTextName.defaultTextFormat = format;
		//		playerTextName.x = -50;
		//		playerTextName.y = -65;
		//		playerTextName.width = 100;
		//		playerTextName.height = 24;
		//		playerTextName.mouseEnabled = false;
		//		if (NOM.charAt(0) == "*") {
		//			playerTextName.text = NOM.substr(1);
		//		} else {
		//			playerTextName.text = NOM;
		//		}
		//		addChild(playerTextName);
		//		playerTextName.cacheAsBitmap = true;
		//
		animation(0);
	}

	////////////////////////////////////////////////////////////
	//// Functions
	////////////////////////////////////////////////////////////

	public function activerProtection():void {
		if (estMort) {
			return;
		}
		if (!casque) {
			casque = Mouton.recupClip("$Casque");
		}
		if (estJoueurPrincipal) {
			if (!peutSeProteger) {
				return;
			}
			peutSeProteger = false;
			Mouton.instance.module801.sendToServer(8, 4)
		}
		protectionEnCours = true;
		finProtection = getTimer() + 1500;
		addChild(casque);
	}

	public function retirerProtection():void {
		if (casque && casque.parent) {
			removeChild(casque);
		}
		protectionEnCours = false;
	}

	public function ajouterTexteDoge(MESSAGE:String):void {
		if (listeTexteDoge.length >= 6) {
			return;
		}
		indexTexteDoge++;
		var texte:TexteDoge = new TexteDoge(MESSAGE);
		if (indexTexteDoge % 2) {
			texte.x = 20;
		} else {
			texte.x = -20 - texte.width;
		}
		texte.y = -25 - Math.random() * 30;
		addChild(texte);
		listeTexteDoge.push(texte);
	}

	public function synchronisationJoueurPrincipal():void {
		var codeDirection:int = 0;
		if (droiteEnCours) {
			codeDirection = 1;
		} else if (gaucheEnCours) {
			codeDirection = 2;
		}
		Mouton.instance.module801.sendToServer(4, Mouton.instance.codePartieEnCours, codeDirection, int(x), int(y), int(vitesseX), int(vitesseY));
	}

	public function defVersLaDroite(OUI:Boolean):void {
		if (OUI && !regardeVersLaDroite) {
			regardeVersLaDroite = true;
			zoneAnim.x = -50;
			zoneAnim.scaleX = 1;
		} else if (!OUI && regardeVersLaDroite) {
			regardeVersLaDroite = false;
			zoneAnim.x = 50;
			zoneAnim.scaleX = -1;
		}
	}

	public function animation(CODE:int):void {
		var anim:Particule = listeAnim[CODE];
		anim.demandeDestruction = false;
		if (CODE == 0) {
			anim.lectureDepuisImage(int(Math.random() * anim.nombreImageTotale));
		} else {
			anim.lectureDepuisImage(0);
		}
		zoneAnim.listeParticule[0] = anim;
		zoneAnim.demandeRendu = true;
	}

	public function mort(CODE_PIEGE:int, DEMANDE_SERVEUR:Boolean = false):void {
		if (!estMort) {
			estMort = true;
			if (estJoueurPrincipal && !DEMANDE_SERVEUR) {
				// Envoie de la mort au serveur
				synchronisationJoueurPrincipal();
				Mouton.instance.module801.sendToServer(6, Mouton.instance.codePartieEnCours, CODE_PIEGE);
			}
			if (CODE_PIEGE == 20) {
				animation(2);
			} else if (CODE_PIEGE == 21) {
				animation(3);
			} else if (CODE_PIEGE == 2) {
				animation(4);
			} else if (CODE_PIEGE == 3) {
				animation(5);
			} else if (CODE_PIEGE == 22) {
				animation(6);
			} else if (CODE_PIEGE == 23) {
				animation(7);
			} else if (CODE_PIEGE == 44) {
				animation(8);
			} else if (CODE_PIEGE == 33) {
				animation(5);
			} else {
				animation(1);
			}
			MondeMouton.mondeEnCours.effetMortMouton(this, CODE_PIEGE);
		}
	}

}
}
