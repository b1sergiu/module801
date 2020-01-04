package Interfaces {

import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class InterfaceAscenseur extends Sprite {

	private var Texte:TextField;
	private var Largeur:int;
	private var Hauteur:int;

	private var ClipAscenseur:Sprite;
	private var ClipBarre:Sprite;
	private var PuissanceMolette:int;
	private var AscenseurCF:uint;
	private var AscenseurCB:uint;
	private var FinEnCours:Boolean = false;
	private var LimiteBarreY:int;
	private var DécalageBarreY:int;
	private var fonctionChangementPosition:Function;


	public function InterfaceAscenseur(TEXTE:TextField, PUISSANCE_MOLETTE:int = 1, COULEUR_FOND:uint = 0x202B35, COULEUR_BARRE:uint = 0x3C5064) {
		Texte = TEXTE;
		Texte.mouseWheelEnabled = false;
		Texte.mouseEnabled = true;
		//
		mouseChildren = false;
		mouseEnabled = true;
		//
		PuissanceMolette = PUISSANCE_MOLETTE;
		//
		ClipAscenseur = new Sprite();
		//
		AscenseurCF = COULEUR_FOND;
		AscenseurCB = COULEUR_BARRE;
		//
		var FondSouris:Shape = new Shape();
		ClipAscenseur.addChild(FondSouris);
		//
		var Fond:Shape = new Shape();
		ClipAscenseur.addChild(Fond);
		//
		ClipBarre = new Sprite();
		ClipAscenseur.addChild(ClipBarre);
		addChild(ClipAscenseur);
		//
		//var Cadre:Shape = new Shape();
		//Cadre.graphics.lineStyle(1, 0, 1, true);
		//Cadre.graphics.drawRect(0, 0, 3, Hauteur);
		//Cadre.graphics.endFill();
		//ClipAscenseur.addChild(Cadre);
		//
		majTaille();
		//
		addEventListener(MouseEvent.MOUSE_WHEEL, Utilisation_Molette);
		Texte.addEventListener(MouseEvent.MOUSE_WHEEL, Utilisation_Molette);
		addEventListener(MouseEvent.MOUSE_DOWN, Clique_Ascenseur);
		//
		Texte.parent.addChild(this);
		visible = false;
	}

	public function Rendu_Ascenseur(POS:int):void {
		if (Texte.maxScrollV == 1) {
			Texte.scrollV = 1;
			visible = false;
			FinEnCours = false;
		} else {
			var NombreLigne:int = Texte.numLines;
			var PB:Number = (NombreLigne - Texte.maxScrollV) / NombreLigne;
			//
			FinEnCours = Texte.scrollV == Texte.maxScrollV;
			//
			visible = true;
			//
			var HauteurBarre:int = int(Hauteur * PB);
			if (HauteurBarre < 10) {
				HauteurBarre = 10;
			}
			//
			ClipBarre.graphics.clear();
			ClipBarre.graphics.beginFill(AscenseurCB);
			ClipBarre.graphics.drawRoundRect(0, 0, 3, HauteurBarre, 4);
			ClipBarre.graphics.endFill();
			//
			LimiteBarreY = Hauteur - HauteurBarre;
			//
			if (ClipBarre.y > LimiteBarreY) {
				FinEnCours = true;
			}
			//
			if (POS == 0) {
				Texte.scrollV = 0;
				ClipBarre.y = 0;
			} else if (POS == 1) {
				if (FinEnCours) {
					Texte.scrollV = Texte.maxScrollV;
					ClipBarre.y = LimiteBarreY;
				}
			} else if (POS == 2) {
				Texte.scrollV = Texte.maxScrollV;
				ClipBarre.y = LimiteBarreY;
			}
		}
	}

	private function Utilisation_Molette(E:MouseEvent):void {
		if (visible) {
			var Décalage:int;
			if (E.delta < 0) {
				Décalage = PuissanceMolette;
			} else {
				Décalage = (-PuissanceMolette);
			}
			//
			Texte.scrollV += Décalage;
			//
			var PB:Number = (Texte.scrollV - 1) / (Texte.maxScrollV - 1);
			//
			ClipBarre.y = int(LimiteBarreY * PB);
			//
			FinEnCours = Texte.scrollV == Texte.maxScrollV;
			if (fonctionChangementPosition != null) {
				fonctionChangementPosition();
			}
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
		var Pos:int = Math.ceil(Texte.maxScrollV * PB);
		if (Pos == 0) {
			Pos = 1;
		}
		Texte.scrollV = Pos;
		//
		FinEnCours = Texte.scrollV == Texte.maxScrollV;
		//E.updateAfterEvent();
		if (fonctionChangementPosition != null) {
			fonctionChangementPosition();
		}
	}

	public function majTaille(POS_RENDU:int = 0):void {
		Hauteur = Texte.height - 10;
		Largeur = Texte.width;

		ClipAscenseur.x = Texte.x + Largeur + 5;
		ClipAscenseur.y = Texte.y + 5;

		var FondSouris:Shape = ClipAscenseur.getChildAt(0) as Shape;
		FondSouris.graphics.clear();
		FondSouris.graphics.beginFill(0, 0);
		FondSouris.graphics.drawRect(-5, 0, 13, Hauteur);
		FondSouris.graphics.endFill();

		var Fond:Shape = ClipAscenseur.getChildAt(1) as Shape;
		Fond.graphics.clear();
		Fond.graphics.beginFill(AscenseurCF);
		Fond.graphics.drawRoundRect(0, 0, 3, Hauteur, 4);
		Fond.graphics.endFill();
		//
		Rendu_Ascenseur(POS_RENDU);
	}

	public function definirFonctionPosition(FONCTION_POS:Function):void {
		fonctionChangementPosition = FONCTION_POS;
	}

	public function estALaFin():Boolean {
		return FinEnCours;
	}
}
}