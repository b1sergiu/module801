/**
 * Auteur : Tigrou
 * Date : 18/04/2015 - 09:28
 */
package {

import Interfaces.InterfaceListe;

import atelier801.Chat801;
import atelier801.Console801;
import atelier801.Module801;

import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.ProgressEvent;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import outils.ToucheClavier;
import outils._particules.ParticuleZero;

[SWF(width="640", height="480", frameRate="60", backgroundColor="#999999")]
public class Mouton extends Sprite {
	
	////////////////////////////////////////////////////////////
	//// Variables
	////////////////////////////////////////////////////////////

	[Embed("../ressources.swf", mimeType="application/octet-stream")]
	static public var classeRessources:Class;

	static public var instance:Mouton;

	static public var nomSalon:String = "";
	public var module801:Module801;
	public var nomJoueurPrincipal:String;
	private var estAdmin:Boolean;
	public var console:Console801;
	private var premierAffichage:Boolean = false;
	private var chat:Chat801;

	private var mondeEnCours:MondeMouton;
	private var chargeurRessources:Loader;
	public var codePartieEnCours:int = 0;
	public var bergerEnCours:JoueurMouton;
	private var ecranChargement:MovieClip;
	private var donneeChargee:int = 0;
	public var clipListeJoueur:InterfaceListe;

	static public var listeTacheSangMur:ParticuleZero;
	static public var listeTacheSangSol:ParticuleZero;
	
	
	////////////////////////////////////////////////////////////
	//// Constructeur
	////////////////////////////////////////////////////////////
	
	public function Mouton() {
		if (stage) {
			initialisation();
		} else {
			addEventListener(Event.ADDED_TO_STAGE, initialisation);
		}
		instance = this;
	}

	private function initialisation(EVE:Event = null):void {
		removeEventListener(Event.ADDED_TO_STAGE, initialisation);
		chargeurRessources = new Loader();
		var contexte:LoaderContext = new LoaderContext();
		if (Capabilities.playerType == "Desktop") {
			Object(contexte).allowCodeImport = true;
		}
		contexte.applicationDomain = ApplicationDomain.currentDomain;
		chargeurRessources.contentLoaderInfo.addEventListener(Event.COMPLETE, chargementRessourcesOkay);
		chargeurRessources.loadBytes(new (classeRessources)(), contexte);
	}

	private function chargementRessourcesOkay(EVE:Event):void {
		module801 = new Module801("shepherd", "server1.module801.com", messageReceive, logServeur);
		module801.addEventListener(Event.INIT, init);
		module801.addEventListener(Event.CONNECT, connexionOk);
		module801.addEventListener(Event.CLOSE, deconnexion);
		module801.addEventListener(ProgressEvent.PROGRESS, boucleChargement);
		addChild(module801);
		console = module801.getConsole();
		console.resize(400, 200);
		//		addChild(console);
		//
		ecranChargement = recupClip("$ClipChargeur");
		addChild(ecranChargement);
		//
		console.addCommand("reload", module801.reloadLuaServerFromLocalFile);
		//
		stage.scaleMode = StageScaleMode.SHOW_ALL;
		//
		listeTacheSangMur = new ParticuleZero(recupClip("$TacheMur"));
		listeTacheSangSol = new ParticuleZero(recupClip("$TacheSol"));
		//
		JoueurMouton.listeAnimMouton = new Vector.<ParticuleZero>(9, true);
		for (var i:int = 0; i < JoueurMouton.listeAnimMouton.length; i++) {
			JoueurMouton.listeAnimMouton[i] = new ParticuleZero(recupClip("$Anim_" + i));
		}
	}

	private function boucleChargement(EVE:ProgressEvent):void {
		if (EVE.bytesLoaded > donneeChargee) {
			donneeChargee = EVE.bytesLoaded;
		}
		var pourcentage:int = (donneeChargee / EVE.bytesTotal) * 100;
		TextField(ecranChargement.texte).text = pourcentage + "% - " + int(donneeChargee / 1024) + " kb";
	}

	////////////////////////////////////////////////////////////
	//// Méthodes statiques
	////////////////////////////////////////////////////////////

	static public function recupClip(NOM:String):MovieClip {
		return new (ApplicationDomain.currentDomain.getDefinition(NOM) as Class)();
	}

	////////////////////////////////////////////////////////////
	//// Functions
	////////////////////////////////////////////////////////////

	private function init(EVE:Event):void {
		if (ecranChargement && ecranChargement.parent) {
			MovieClip(ecranChargement.anim).gotoAndStop(1);
			ecranChargement.parent.removeChild(ecranChargement);
		}
		stage.addEventListener(KeyboardEvent.KEY_DOWN, clavierEntree);
		module801.setLoginUI(module801.getImage("http://www.transformice.com/images/x_divers/mouton.png"));
	}

	private function connexionOk(EVE:Event):void {
	}

	private function deconnexion(EVE:Event):void {
		for (var i:int = 0; i < numChildren; i++) {
			if (getChildAt(i) != module801) {
				removeChildAt(i);
				i--;
			}
		}
	}

	private function logServeur(message:String):void {
		console.newServerLog(message);
	}

	private function nouveauMessageChat(AUTEUR:String, MESSAGE:String):void {
		if (MESSAGE && MESSAGE.length < 8) {
			var joueur:JoueurMouton = JoueurMouton.indexJoueurs[AUTEUR];
			if (joueur) {
				joueur.ajouterTexteDoge(MESSAGE);
			}
		}
	}

	private function majClipListeJoueur():void {
		if (!clipListeJoueur) {
			clipListeJoueur = new InterfaceListe(140, 140, 20, false);
			clipListeJoueur.x = chat.x + chat.width + 10;
			clipListeJoueur.y = chat.y;
			clipListeJoueur.Ascenseur(40, 0x333333, 0x999999);
			addChild(clipListeJoueur);
			premierAffichage = true;
		}
		clipListeJoueur.Vider();
		var i:int = -1;
		var num:int = JoueurMouton.listeJoueurs.length;
		while (++i < num) {
			var mouton:JoueurMouton = JoueurMouton.listeJoueurs[i];
			clipListeJoueur.Ajout_Element(mouton.clipJoueurListe);
		}
		clipListeJoueur.Rendu("point", Array.NUMERIC | Array.DESCENDING);
		if (premierAffichage) {
			premierAffichage = false;
			clipListeJoueur.Position(0);
		} else {
			clipListeJoueur.Position(1);
		}
	}

	private function retourTemps():void {
		MondeMouton.anomalieTemps = true;
	}

	private function messageReceive(id:int, msg:Array):void {
		var joueur:JoueurMouton;
		// Bonjour
		if (id == 0) {
			nomJoueurPrincipal = msg[0];
			estAdmin = msg[1] == "1";
			// Chat
			chat = module801.getChat(300, 140, nouveauMessageChat);
			chat.x = 5;
			chat.y = 480 - 140;
			addChild(chat);
			majClipListeJoueur();
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.addEventListener(KeyboardEvent.KEY_UP, clavierSortie);
			addChild(recupClip("$Cadre"));
			//			module801.infoTemps(retourTemps);
			return;
		}
		// Maj curseur
		if (id == 2) {
			mondeEnCours.majPositionCurseur(msg[0], msg[1]);
			return;
		}
		// Point
		if (id == 3) {
			joueur = JoueurMouton.indexJoueurs[msg[0]];
			if (joueur) {
				joueur.clipJoueurListe.majPoint(msg[1]);
			}
			return;
		}
		// Déplacement
		if (id == 4) {
			joueur = JoueurMouton.indexJoueurs[msg[0]];
			if (joueur) {
				var direction:int = msg[1];
				joueur.droiteEnCours = false;
				joueur.gaucheEnCours = false;
				if (direction == 1) {
					joueur.droiteEnCours = true;
				} else if (direction == 2) {
					joueur.gaucheEnCours = true;
				}
				var posX:int = msg[2];
				var posY:int = msg[3];
				var distanceX:int = Math.abs(posX - joueur.x);
				var distanceY:int = Math.abs(posX - joueur.x);
				if (distanceX > 4) {
					joueur.x = posX;
				}
				if (distanceY > 4) {
					joueur.y = posY;
				}
				joueur.vitesseX = msg[4];
				joueur.vitesseY = msg[5];
			}
			return;
		}
		// Monde
		if (id == 5) {
			if (mondeEnCours) {
				if (mondeEnCours.parent) {
					mondeEnCours.parent.removeChild(mondeEnCours);
				}
			}
			codePartieEnCours = msg[1];
			mondeEnCours = new MondeMouton(msg[0]);
			addChildAt(mondeEnCours, 1);
			majClipListeJoueur();
			return;
		}
		// Mort d'un joueur
		if (id == 6) {
			joueur = JoueurMouton.indexJoueurs[msg[0]];
			if (joueur) {
				joueur.mort(msg[1], true);
			}
			return;
		}
		// Déclenchement d'un piège
		if (id == 7) {
			mondeEnCours.activerPiege(msg[0], msg[1]);
			return;
		}
		// Protection
		if (id == 8) {
			joueur = JoueurMouton.indexJoueurs[msg[0]];
			if (joueur) {
				joueur.activerProtection();
			}
			return;
		}
		// Respawn
		if (id == 9) {
			joueur = JoueurMouton.indexJoueurs[msg[0]];
			if (joueur) {
				joueur.estMort = false;
				joueur.x = msg[1];
				joueur.y = msg[2];
				joueur.vitesseDeplacement = msg[3];
				mondeEnCours.ajouterJoueur(joueur);
			}
			return;
		}
		// Nouveau joueur
		if (id == 10) {
			var nomJoueur:String = msg[0];
			joueur = new JoueurMouton(nomJoueur, nomJoueur == nomJoueurPrincipal);
			JoueurMouton.indexJoueurs[nomJoueur] = joueur;
			JoueurMouton.listeJoueurs.push(joueur);
			joueur.estMort = msg[1];
			joueur.x = int(msg[2]);
			joueur.y = int(msg[3]);
			if (!joueur.estMort) {
				mondeEnCours.ajouterJoueur(joueur);
			}
			majClipListeJoueur();
			return;
		}
		// Deco joueur
		if (id == 11) {
			joueur = JoueurMouton.indexJoueurs[msg[0]];
			if (joueur) {
				delete JoueurMouton.indexJoueurs[joueur.nomJoueur];
				var index:int = JoueurMouton.listeJoueurs.indexOf(joueur);
				if (index != -1) {
					JoueurMouton.listeJoueurs.splice(index, 1);
				}
				if (joueur.parent) {
					joueur.parent.removeChild(joueur);
				}
				majClipListeJoueur();
			}
			return;
		}
		// Nom salon
		if (id == 37) {
			nomSalon = msg[0];
			JoueurMouton.listeJoueurs = new Vector.<JoueurMouton>();
			JoueurMouton.indexJoueurs = new Dictionary();
			return;
		}
		// Temps restant
		if (id == 38) {
			mondeEnCours.tempsBaseRestant = msg[0];
			mondeEnCours.tempsReceptionTempsRestant = getTimer();
			mondeEnCours.majTexteInfo();
			return;
		}
		// Nom du berger
		if (id == 39) {
			joueur = JoueurMouton.indexJoueurs[msg[0]];
			var joueurEnVie:int = msg[1];
			if (joueur) {
				bergerEnCours = joueur;
				if (joueurEnVie > 0) {
					joueur.estMort = true;
					if (joueur.parent) {
						joueur.parent.removeChild(joueur);
					}
				}
				chat.addLine("<BL>" + joueur.nomJoueur + " is your new shepherd!")
			}
			mondeEnCours.majTexteInfo();
			return;
		}
		// Piège pour le berger
		if (id == 40) {
			mondeEnCours.initialisationPiegeBerger(msg[0], msg[1]);
			return;
		}
		throw new Error("Message inconnu : [" + id + "] " + msg);
	}

	private function clavierEntree(EVE:KeyboardEvent):void {
		var code:int = EVE.keyCode;
		if (code == ToucheClavier.T_TAB && EVE.shiftKey) {
			if (console.parent) {
				console.parent.removeChild(console);
			} else {
				addChild(console);
			}
			return;
		}
		if (JoueurMouton.joueurPrincipal && !JoueurMouton.joueurPrincipal.estMort) {
			var champsFocus:TextField = stage.focus as TextField;
			if (champsFocus && champsFocus.type == TextFieldType.INPUT) {
				return;
			}
			if (!JoueurMouton.joueurPrincipal.droiteEnCours && (code == ToucheClavier.T_DROITE || code == ToucheClavier.T_D)) {
				JoueurMouton.joueurPrincipal.droiteEnCours = true;
				JoueurMouton.joueurPrincipal.synchronisationJoueurPrincipal();
				return;
			}
			if (!JoueurMouton.joueurPrincipal.gaucheEnCours && (code == ToucheClavier.T_GAUCHE || code == ToucheClavier.T_Q || code == ToucheClavier.T_A)) {
				JoueurMouton.joueurPrincipal.gaucheEnCours = true;
				JoueurMouton.joueurPrincipal.synchronisationJoueurPrincipal();
				return;
			}
			if (JoueurMouton.joueurPrincipal.peutSauter && (code == ToucheClavier.T_HAUT || code == ToucheClavier.T_Z || code == ToucheClavier.T_W)) {
				JoueurMouton.joueurPrincipal.peutSauter = false;
				JoueurMouton.joueurPrincipal.vitesseY = -200;
				JoueurMouton.joueurPrincipal.synchronisationJoueurPrincipal();
				return;
			}
			if (code == ToucheClavier.T_ESPACE) {
				JoueurMouton.joueurPrincipal.activerProtection();
				return;
			}
		}
	}

	private function clavierSortie(EVE:KeyboardEvent):void {
		var code:int = EVE.keyCode;
		if (JoueurMouton.joueurPrincipal.droiteEnCours && (code == ToucheClavier.T_DROITE || code == ToucheClavier.T_D)) {
			JoueurMouton.joueurPrincipal.droiteEnCours = false;
			JoueurMouton.joueurPrincipal.synchronisationJoueurPrincipal();
			return;
		}
		if (JoueurMouton.joueurPrincipal.gaucheEnCours && (code == ToucheClavier.T_GAUCHE || code == ToucheClavier.T_Q || code == ToucheClavier.T_A)) {
			JoueurMouton.joueurPrincipal.gaucheEnCours = false;
			JoueurMouton.joueurPrincipal.synchronisationJoueurPrincipal();
			return;
		}
	}
	
}
}
