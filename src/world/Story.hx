package world;
import com.haxepunk.Entity;
import com.haxepunk.tmx.TmxMap;
import com.haxepunk.Tween;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.utils.Ease;
import com.haxepunk.utils.Key;
import openfl.Assets;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.gui.Button;
import com.haxepunk.gui.CheckBox;
import com.haxepunk.gui.Control;
import com.haxepunk.gui.Label;
import com.haxepunk.gui.RadioButton;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.utils.Input;

/**
 * ...
 * @author Samuel Bouchet
 */

class Story extends Scene
{
	
	public static var instance:Scene ;
	public static var guiInitialized:Bool = false ;

	public function new()
	{
		super();
	
		instance = this;
	}
	
	override public function begin()
	{
		super.begin();

		var title = new Label(
			"Oh bonjour, comment allez vous ?" + '\n' +
			"Je resterais bien discuter avec vous mais" + '\n' +
			"apres un passage au coeur d'une supernova" + '\n' +
			"le processeur temporel de mon vaisseau rencontre quelques" + '\n' +
			"difficultes." + '\n' +
			'\n' +
			"    Je ferais mieux de le reparer au plus vite" + '\n' +
			"    ou nous risquons de provoquer une singularite," + '\n' +
			"    sans grandes consequences rassurez-vous," + '\n' +
			"    a moins qu'elle ne dechire l'espace temps, ce qui est tres probable." + '\n' +
			'\n' +
			"Il semblerait que la salle de machines soit prise dans une boucle temporelle" + '\n' +
			"restons prudents," + '\n' +
			"nous ne voudrions pas tomber sur nous meme et causer un" + '\n' +
			"paradoxe, n'est-ce pas?" + '\n' +
			'\n' +
			'\n' +
			"    Vous etes pret ?" + '\n' +
			"    Alors Allons-y!"
		) ;
		title.font = openfl.Assets.getFont("font/pf_ronda_seven.ttf").fontName;
		title.color = 0xFFFFFF ;
		title.size = 8 ;
		title.x = Math.round((HXP.screen.width - title.width) / 2) ;
		title.y = 30 ;
		title.shadowColor = 0x000000;
		add(title) ;

		//var t = new VarTween( null, Looping ) ;
		//t.tween( continueLabel, "alpha", 0, 100, Ease.sineInOut ) ;
		//this.addTween( t ) ;
		//t.start() ;

	}
	
	override public function update()
	{
		if (Input.pressed(Key.NUMPAD_0)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _01.tmx"));
		} else if (Input.pressed(Key.NUMPAD_1)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _02.tmx"));
		} else if (Input.pressed(Key.NUMPAD_2)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _03.tmx"));
		} else if (Input.pressed(Key.NUMPAD_3)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _04.tmx"));
		} else if (Input.pressed(Key.NUMPAD_4)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _05.tmx"));
		} else if (Input.pressed(Key.NUMPAD_5)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _06.tmx"));
		} else if (Input.pressed(Key.NUMPAD_6)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _07.tmx"));
		} else if (Input.pressed(Key.NUMPAD_7)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _08.tmx"));
		} else if (Input.pressed(Key.NUMPAD_8)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _09.tmx"));
		} else if (Input.pressed(Key.NUMPAD_9)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _10.tmx"));
		} else if (Input.pressed(Key.A)) {
			HXP.scene = new GameWorld(Assets.getText("map/testLD _11.tmx"));
		} else if ( Input.pressed(com.haxepunk.utils.Key.ANY) ) {
			var levels = new Array<String>();
			
			for (i in 1...21) {
				levels.push("map/testLD _"+(Std.string(i).length == 1 ? "0" + Std.string(i) : Std.string(i))+".tmx");
			}
			var rand = Math.floor(Math.random() * levels.length);
			
			try {
				HXP.scene = new GameWorld(Assets.getText(levels[rand]));
			}catch (e:Dynamic) {
				trace("fail loading level "+e);
				// fall back en cas de pb avec un niveau
				HXP.scene = new GameWorld(Assets.getText("map/testLD _01.tmx"));
				
			}
			
		}
		super.update();
	}
	
	override public function end()
	{
		WelcomeWorld.instance.music.stop();
		removeAll();
		super.end();
	}
	
}