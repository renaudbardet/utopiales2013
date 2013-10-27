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
				var saveLbl = new Label("Score sauvegarde !");
					saveLbl.color = 0xFFFFFF ;
					saveLbl.size = 10;
					saveLbl.y = HXP.screen.height - 15;
					saveLbl.x = 5;
					add(saveLbl);
				
				var urlLoaderGet:URLLoader = new URLLoader(new URLRequest("http://samuel-bouchet.fr/utopiales2013/score.php?action=get&level=" + _niveau));
				urlLoaderGet.addEventListener(Event.COMPLETE, function(e:Event) {
					var highscores:Array<Dynamic> = cast(Json.parse(e.target.data));
					var highscoreStr:String = "Meilleurs scores :\n";
					for (hs in highscores) {
						highscoreStr += hs.score + "\n";
					}
					var highscoreLbl = new Label(highscoreStr);
					highscoreLbl.color = 0xFFFFFF ;
					highscoreLbl.size = 10;
					highscoreLbl.x = 5;
					highscoreLbl.y = 5;
					add(highscoreLbl);
			});
		});
		
		var bgG:Stamp = new Stamp("gfx/accueil.png");
		var bg = new Entity();
		bg.graphic = bgG;
		bg.layer = 9001;
		
		var scoreLbl:Label = new Label("Votre score : " + _score);
		scoreLbl.color = 0xFFFFFF ;
		scoreLbl.size = 40;
		scoreLbl.x = Math.floor(HXP.screen.width / 2 - scoreLbl.width / 2);
		scoreLbl.y = Math.floor(HXP.screen.height / 2 - scoreLbl.height / 2) - 20;
		
		var niveauLbl:Label = new Label("Salle « " + _niveau + " »");
		niveauLbl.color = 0xFFFFFF ;
		niveauLbl.size = 20;
		niveauLbl.x = Math.floor(HXP.screen.width / 2 - niveauLbl.width / 2);
		niveauLbl.y = 30;
		
		continueLabel = new Label("Appuyez sur une touche pour recommencer") ;
		continueLabel.color = 0xFFFFFF ;
		continueLabel.size = 16 ;
		continueLabel.font = Assets.getFont("font/lythgame.ttf").fontName;
		continueLabel.x = Math.floor((HXP.screen.width - continueLabel.width) / 2) ;
		continueLabel.y = Math.floor(HXP.screen.height - 60) ;
		
	
		
		add(bg);
		add(scoreLbl) ;
		add(niveauLbl) ;
		add(continueLabel) ;
	}
	
	override public function update()
	{
		if (Input.pressed(com.haxepunk.utils.Key.NUMPAD_ADD)) {
			continueLabel.size ++;
			trace(continueLabel.size);
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