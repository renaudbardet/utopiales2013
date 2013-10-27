package world;

import com.haxepunk.Entity;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.gui.Label;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.utils.Input;
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