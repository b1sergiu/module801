/**
 * Auteur : Tigrou
 * Date : 19/04/2015 - 16:26
 */
package outils {

import flash.display.MovieClip;
import flash.text.TextField;
import flash.text.TextFormat;

public class ClipJoueurListe extends MovieClip {
	
	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	public var champsTexte:TextField;
	public var point:int = 0;
	private var nomJoueur:String;
	
	////////////////////////////////////////////////////////////
	//// Constructeur
	////////////////////////////////////////////////////////////
	
	public function ClipJoueurListe(NOM:String) {
		nomJoueur = NOM;
		champsTexte = new TextField();
		champsTexte.defaultTextFormat = new TextFormat("Verdana", 12, 0x222222, true);
		champsTexte.height = 20;
		champsTexte.width = 140;
		champsTexte.mouseEnabled = false;
		champsTexte.multiline = false;
		champsTexte.wordWrap = false;
		addChild(champsTexte);
		//
		graphics.beginFill(0x666666);
		graphics.drawRect(0, 0, champsTexte.width, champsTexte.height);
		graphics.endFill();
		//
		cacheAsBitmap = true;
		majPoint(0);
	}

	////////////////////////////////////////////////////////////
	//// Méthodes
	////////////////////////////////////////////////////////////

	public function majPoint(POINT:int):void {
		point = POINT;
		champsTexte.text = nomJoueur + " - " + POINT;
	}
	
}
}
