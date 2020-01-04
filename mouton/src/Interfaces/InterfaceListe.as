package Interfaces {

import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;

public class InterfaceListe extends Sprite {
	private var Largeur:int;
	private var Hauteur:int;
	private var clipFond:Shape;
	private var Masque:Shape;
	private var Liste:Array = new Array();
	private var Boite:Sprite = new Sprite();
	private var FonctionRendu:Function;
	private var RenduRestant:int;
	private var RenduEnCours:int;
	private var BaseY:int;
	private var Interval:int;

	private var AscenseurActif:Boolean = false;
	private var puissanceMolette:int;
	private var ClipAscenseur:Sprite;
	private var ClipBarre:Sprite;
	private var HauteurAscenseur:int;
	private var AscenseurCF:uint;
	private var AscenseurCB:uint;
	private var LimiteY:int;
	private var LimiteBarreY:int;
	private var DécalageBarreY:int;
	private var FinEnCours:Boolean = false;

	private var HauteurFixe:Boolean;
	public var HauteurClip:int;

	public var VignetteTexte:String;
	public var VignetteFixe:int;
	public var VignetteFixeX:int;
	public var VignetteFixeY:int;
	public var VignetteLargeur:int;


	public function InterfaceListe(LARGEUR:int, HAUTEUR:int, HAUTEUR_FIXE:int = 0, FOND:Boolean = true, INTERVAL:int = 0) {
		mouseEnabled = false;
		Boite.mouseEnabled = false;
		Interval = INTERVAL;
		//
		if (HAUTEUR_FIXE == 0) {
			HauteurFixe = false;
		} else {
			HauteurFixe = true;
			HauteurClip = HAUTEUR_FIXE + Interval;
		}
		//
		clipFond = new Shape();
		Masque = new Shape();
		Boite.mask = Masque;
		//
		majTaille(LARGEUR, HAUTEUR, FOND);
		//
		if (clipFond) {
			addChild(clipFond);
		}
		addChild(Boite);
		addChild(Masque);
	}


	public function majTaille(LARGEUR:int = 0, HAUTEUR:int = 0, FOND:Boolean = true):void {
		if (!Hauteur || HAUTEUR != 0) {
			Hauteur = HAUTEUR;
		}
		if (!Largeur || LARGEUR != 0) {
			Largeur = LARGEUR;
		}
		HauteurAscenseur = Hauteur - 20;
		//
		clipFond.graphics.clear();
		Masque.graphics.clear();
		if (FOND) {
			clipFond.graphics.lineStyle(2, 0, 1, true);
			clipFond.graphics.beginFill(0x3C3C55);
			clipFond.graphics.drawRoundRect(0, 0, Largeur, Hauteur, 20);
			clipFond.graphics.endFill();
			//
			Masque.graphics.beginFill(0);
			Masque.graphics.drawRoundRect(1, 1, Largeur - 2, Hauteur - 2, 20);
			Masque.graphics.endFill();
		} else {
			clipFond.graphics.beginFill(0, 0);
			clipFond.graphics.drawRect(0, 0, Largeur, Hauteur);
			clipFond.graphics.endFill();
			//
			Masque.graphics.beginFill(0);
			Masque.graphics.drawRect(1, 1, Largeur, Hauteur);
			Masque.graphics.endFill();
		}
		// Maj taille ascenseur
		if (AscenseurActif) {
			ClipAscenseur.x = Largeur - 3;
			//
			var fondSouris:Shape = ClipAscenseur.getChildAt(0) as Shape;
			fondSouris.graphics.clear();
			fondSouris.graphics.beginFill(0, 0);
			fondSouris.graphics.drawRect(-5, 0, 13, HauteurAscenseur);
			fondSouris.graphics.endFill();

			var fondAscenseur:Shape = ClipAscenseur.getChildAt(1) as Shape;
			fondAscenseur.graphics.clear();
			fondAscenseur.graphics.beginFill(AscenseurCF);
			fondAscenseur.graphics.drawRoundRect(0, 0, 3, HauteurAscenseur, 4);
			fondAscenseur.graphics.endFill();
			//
			Rendu_Ascenseur();
		}
	}

	public function Ascenseur(PUISSANCE_MOLETTE:int = 80, COULEUR_FOND:uint = 0x202B35, COULEUR_BARRE:uint = 0x3C5064):void {
		if (!AscenseurActif) {
			mouseEnabled = true;
			AscenseurActif = true;
			//
			puissanceMolette = PUISSANCE_MOLETTE;
			//
			ClipAscenseur = new Sprite();
			ClipAscenseur.x = Largeur - 3;
			ClipAscenseur.y = 10;
			//
			AscenseurCF = COULEUR_FOND;
			AscenseurCB = COULEUR_BARRE;
			//
			var FondSouris:Shape = new Shape();
			FondSouris.graphics.beginFill(0, 0);
			FondSouris.graphics.drawRect(-5, 0, 13, HauteurAscenseur);
			FondSouris.graphics.endFill();
			ClipAscenseur.addChild(FondSouris);
			//
			var Fond:Shape = new Shape();
			Fond.graphics.beginFill(AscenseurCF);
			Fond.graphics.drawRoundRect(0, 0, 3, HauteurAscenseur, 4);
			Fond.graphics.endFill();
			ClipAscenseur.addChild(Fond);
			//
			ClipBarre = new Sprite();
			ClipAscenseur.addChild(ClipBarre);
			addChild(ClipAscenseur);
			//
			//var Cadre:Shape = new Shape();
			//Cadre.graphics.lineStyle(1, 0, 1, true);
			//Cadre.graphics.drawRect(0, 0, 3, HauteurAscenseur);
			//Cadre.graphics.endFill();
			//ClipAscenseur.addChild(Cadre);
			//
			ClipAscenseur.mouseChildren = false;
			//
			addEventListener(MouseEvent.MOUSE_WHEEL, Utilisation_Molette);
			ClipAscenseur.addEventListener(MouseEvent.MOUSE_DOWN, Clique_Ascenseur);
		}
	}

	public function Rendu_Ascenseur():void {
		var PB:Number = Hauteur / BaseY;
		if (PB >= 1) {
			Boite.y = 0;
			ClipAscenseur.visible = false;
			FinEnCours = false;
		} else {
			FinEnCours = Boite.y == LimiteY;
			//
			ClipAscenseur.visible = true;
			//
			var HauteurBarre:int = int(HauteurAscenseur * PB);
			if (HauteurBarre < 10) {
				HauteurBarre = 10;
			}
			//
			ClipBarre.graphics.clear();
			ClipBarre.graphics.beginFill(AscenseurCB);
			ClipBarre.graphics.drawRoundRect(0, 0, 3, HauteurBarre, 4);
			ClipBarre.graphics.endFill();
			//
			LimiteY = Hauteur - BaseY;
			LimiteBarreY = HauteurAscenseur - HauteurBarre;
			//
			if (ClipBarre.y > LimiteBarreY) {
				Boite.y = LimiteY;
				ClipBarre.y = LimiteBarreY;
				FinEnCours = true;
			}
		}
	}

	public function Position(POS:int = 0):void {
		if (POS == 0) {
			Boite.y = 0;
			ClipBarre.y = 0;
		} else if (POS == 1) {
			if (FinEnCours) {
				Boite.y = LimiteY;
				ClipBarre.y = LimiteBarreY;
			}
		} else if (POS == 2) {
			if (ClipAscenseur.visible) {
				Boite.y = LimiteY;
				ClipBarre.y = LimiteBarreY;
			} else {
				Boite.y = 0;
				ClipBarre.y = 0;
			}
		}
	}

	public function Vider():void {
		if (RenduRestant != 0) {
			RenduRestant = 0;
			removeEventListener(Event.ENTER_FRAME, Boucle);
		}
		while (Boite.numChildren != 0) {
			Boite.removeChildAt(0);
		}
		Liste = new Array();
	}

	public function Ajout_Element(ELEMENT:MovieClip, DEVANT:Boolean = false):void {
		ELEMENT.visible = false;
		if (DEVANT) {
			Liste.unshift(ELEMENT);
			Boite.addChildAt(ELEMENT, 0);
		} else {
			Liste.push(ELEMENT);
			Boite.addChild(ELEMENT);
		}
	}

	public function Suppr_Element(ELEMENT:MovieClip):void {
		var Nb:int = Liste.length;
		for (var i:int = 0; i < Nb; i++) {
			if (Liste[i] == ELEMENT) {
				Liste.splice(i, 1);
				Boite.removeChild(ELEMENT);
				return;
			}
		}
	}

	public function recupNbElements():int {
		return Liste.length;
	}

	public function Classer(CLASSEMENT:String, TYPE:int = 0):void {
		Liste.sortOn(CLASSEMENT, TYPE);
	}

	public function Rendu(CLASSEMENT:String = null, TYPE:int = 0, FONCTION:Function = null):void {
		if (CLASSEMENT) {
			Liste.sortOn(CLASSEMENT, TYPE);
		}
		//
		BaseY = 0;
		//
		if (FONCTION != null) {
			RenduRestant = Liste.length;
			RenduEnCours = 0;
			FonctionRendu = FONCTION;
			addEventListener(Event.ENTER_FRAME, Boucle);
		} else {
			var Nb:int = Liste.length;
			for (var i:int = 0; i < Nb; i++) {
				var Element:MovieClip = Liste[i];
				Element.y = BaseY;
				if (HauteurFixe) {
					BaseY += HauteurClip;
				} else {
					BaseY += int(Element.height) + Interval;
				}
				Element.visible = true;
			}
			if (AscenseurActif) {
				Rendu_Ascenseur();
			}
		}
	}

	public function MAJ_Hauteur(POS:int):void {
		BaseY = Boite.height + Interval * 2;
		if (AscenseurActif) {
			Rendu_Ascenseur();
			Position(POS);
		}
	}

	private function Boucle(E:Event):void {
		if (RenduRestant == 0) {
			removeEventListener(Event.ENTER_FRAME, Boucle);
			if (AscenseurActif) {
				Rendu_Ascenseur();
			}
		} else {
			var Element:MovieClip = Liste[RenduEnCours];
			Element = FonctionRendu(Element);
			Element.y = BaseY;
			if (HauteurFixe) {
				BaseY += HauteurClip;
			} else {
				BaseY += int(Element.height) + Interval;
			}
			Element.visible = true;

			RenduEnCours++;
			RenduRestant--;
		}
	}

	private function Utilisation_Molette(E:MouseEvent):void {
		if (AscenseurActif && ClipAscenseur.visible) {
			var decalage:int;
			if (E.delta < 0) {
				decalage = (-puissanceMolette);
			} else {
				decalage = puissanceMolette;
			}
			//
			Boite.y += decalage;
			if (Boite.y > 0) {
				Boite.y = 0;
			} else if (Boite.y < LimiteY) {
				Boite.y = LimiteY;
			}
			//
			var PB:Number = Boite.y / LimiteY;
			//
			ClipBarre.y = int(LimiteBarreY * PB);
		}
	}

	private function Clique_Ascenseur(E:Event):void {
		DécalageBarreY = ClipBarre.mouseY;
		stage.addEventListener(MouseEvent.MOUSE_MOVE, Boucle_Ascenseur);
		stage.addEventListener(MouseEvent.MOUSE_UP, Declique_Ascenseur);
	}

	private function Declique_Ascenseur(E:Event):void {
		stage.removeEventListener(MouseEvent.MOUSE_MOVE, Boucle_Ascenseur);
		stage.removeEventListener(MouseEvent.MOUSE_UP, Declique_Ascenseur);
	}

	private function Boucle_Ascenseur(E:MouseEvent):void {
		var Position:int = ClipAscenseur.mouseY - DécalageBarreY;
		if (Position < 0) {
			Position = 0;
		} else if (Position > LimiteBarreY) {
			Position = LimiteBarreY;
		}
		ClipBarre.y = Position;
		//
		var PB:Number = ClipBarre.y / LimiteBarreY;
		//
		Boite.y = int(LimiteY * PB);
		//
		//		E.updateAfterEvent();
	}
}
}