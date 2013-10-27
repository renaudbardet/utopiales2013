package world;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.gui.Label;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.utils.Input;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import haxe.Json;
import openfl.Assets;

/**
 * ...
 * @author Lythom
 */
class End extends Scene
{
	var _score:String;
	var _niveau:String;
	var continueLabel:Label;
	var phrases:Array<String>;
	var phraseLbl:Label;
	private var i:Int = 0;

	
	public function new(score:String, niveau:String)
	{
		_score = score;
		_niveau = niveau;
		super();
		
	}
	
	override public function begin()
	{
		super.begin();
		
		var urlLoader:URLLoader = new URLLoader(new URLRequest("http://samuel-bouchet.fr/utopiales2013/score.php?action=save&key=qsdfghjkl&pseudo=&score="+_score+"&level="+_niveau));
		urlLoader.addEventListener(Event.COMPLETE, function(e:Event) {
				var saveId:Int = Json.parse(e.target.data);
				var saveLbl = new Label("Score sauvegardé !");
					saveLbl.color = 0xB4B4B4 ;
					saveLbl.size = 8;
					saveLbl.y = HXP.screen.height - saveLbl.height - 3;
					saveLbl.x = HXP.screen.width - saveLbl.width - 3;
					saveLbl.font = openfl.Assets.getFont("font/pf_ronda_seven.ttf").fontName;
					add(saveLbl);
				
				var urlLoaderGet:URLLoader = new URLLoader(new URLRequest("http://samuel-bouchet.fr/utopiales2013/score.php?action=get&level=" + _niveau));
				urlLoaderGet.addEventListener(Event.COMPLETE, function(e:Event) {
					var highscores:Array<Dynamic> = cast(Json.parse(e.target.data));
					var c:Int = 0;
					for (hs in highscores) {
						var score:Label = new Label(hs.score);
						score.x = 445 - score.width;
						score.y = 117 + c * 35;
						score.size = 16;
						score.color = 0x000000;
						score.shadowColor = 0xFFFFFF;
						score.font = openfl.Assets.getFont("font/pf_ronda_seven.ttf").fontName;
						add(score);
						c++;
						if (c >= 5) break;
					}
			});
		});
		
		var bgG:Stamp = new Stamp("gfx/score.png");
		var bg = new Entity();
		bg.graphic = bgG;
		bg.layer = 9001;
		

		phrases = [
			"L'ancien vous, celui que vous avez \nincarné quelques secondes \nauparavant, qui est du coup vivant en même \ntemps que vous maintenant, \nmême si... Bon ! Vous êtes mort.",
			"La vision de votre clone temporel \net de sa méche bien plus brillante, \nvous ont fait sortir les yeux de la \ntête.",
			"BOOM ! Tout l'univers ainsi que les \ndéveloppeurs de ce jeu viennent \nd'exploser.",
			"ZWIP ! Vous détournez le regard \net continuez votre chemin. \nLe Docteur ne cause pas de \nparadoxe.",
			"Zvoush... Un vent frais éparpille \nles corps de vous et tous \nvos clones.",
			"Ouille ! \nL'ancien vous décide de vous \ndémembrer à l'aide de son \ntournevis et de reprendre la même \nroute. Il mourra quand il se \ncroisera de nouveau: vous êtes vengé ! \nDe vous même...",
			"Vous connaissez l'écartelement? \nAvec des chevaux? \nDans une aréne romaine? \nBen pareil mais chez vous. ",
			"Pffiiou ! L'âme bienveillante de \nvotre vaisseau est intervenue \navant que le paradoxe de votre \nrencontre ne cause l'implosion de \nl'UNIVERS ! \nElle vous a tué.",
			"Paradoxe ou pas paradoxe, vous \nvous trouvez super sexy. \nUn petit bisou? Qui ne risque rien... \nWOH ! Vous avez fondu à une \nvitesse !",
			"... Mettez-y un peu du votre, vous \nêtes morts, l'univers a cessé \nd'exister, et en PLUS, votre \nvaisseau n'est toujours pas réparé.",
			"Miroir, mon beau miroir: dis-moi... \nOh, Oh ! Ce n'était pas votre miroir.",
			"Proutch ! \nLe vous du passé a explosé en \npremier, et vous avez été effacé, \ngenre rayé de la liste quoi.",
			"Vous êtes morts. \nEt non, vous ne pouvez pas \navancer les yeux fermés."
		];
		
		var randPhrase = Math.floor(Math.random() * phrases.length);
		phraseLbl = new Label(phrases[randPhrase], 70, 45, 150);
		phraseLbl.color = 0x000000 ;
		phraseLbl.size = 8;
		phraseLbl.font = openfl.Assets.getFont("font/pf_ronda_seven.ttf").fontName;
		
		var niveauLbl:Label = new Label(_niveau);
		niveauLbl.color = 0x000000 ;
		niveauLbl.shadowColor = 0xFFFFFF;
		niveauLbl.size = 16;
		niveauLbl.x = 65 + 164/2 - niveauLbl.width/2;
		niveauLbl.y = 188;
		niveauLbl.font = openfl.Assets.getFont("font/pf_ronda_seven.ttf").fontName;
		
		var scoreLbl:Label = new Label(_score);
		scoreLbl.color = 0x000000 ;
		scoreLbl.shadowColor = 0xFFFFFF;
		scoreLbl.size = 16;
		scoreLbl.x = 65 + 164/2 - scoreLbl.width/2;
		scoreLbl.y = 248;
		scoreLbl.font = openfl.Assets.getFont("font/pf_ronda_seven.ttf").fontName;
		
		continueLabel = new Label("Appuyez sur une touche pour recommencer") ;
		continueLabel.color = 0xFFFFFF ;
		continueLabel.shadowColor = 0x000000;
		continueLabel.size = 16 ;
		continueLabel.font = Assets.getFont("font/lythgame.ttf").fontName;
		continueLabel.x = Math.floor((HXP.screen.width - continueLabel.width) / 2) ;
		continueLabel.y = Math.floor(HXP.screen.height - continueLabel.height - 3) ;
		
		add(bg);
		add(scoreLbl) ;
		add(niveauLbl) ;
		add(continueLabel) ;
		add(phraseLbl);
	}
	
	override public function update()
	{
		if (Input.pressed(com.haxepunk.utils.Key.NUMPAD_ADD)) {
			phraseLbl.text = phrases[i++%phrases.length];
		} else if ( Input.pressed(com.haxepunk.utils.Key.ANY) ) {
			HXP.scene = new WelcomeWorld();
		}
		
		
			
		super.update();
	}
		
	override public function end()
	{
		this.removeAll();
		super.end();
	}
	
}