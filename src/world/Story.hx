package world;
import com.haxepunk.Entity;
import com.haxepunk.Tween;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.utils.Ease;
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
			"               Oh bonjour, comment allez vous ?" + '\n' +
			"          Je resterais bien discuter avec vous mais" + '\n' +
			"          apres un passage au coeur d'une supernova" + '\n' +
			"   le processeur temporel de mon vaisseau rencontre quelques" + '\n' +
			"                            difficultes." + '\n' +
			'\n' +
			"          Je ferais mieux de le reparer au plus vite" + '\n' +
			"         ou nous risquons de provoquer une singularite," + '\n' +
			"sans grandes consequences bien sur, juste la survie de l'univers." + '\n' +
			'\n' +
			"      Il semblerait qu'au sein du vaisseau le temps boucle" + '\n' +
			"         sur lui-meme, je ferais mieux d'etre prudent," + '\n' +
			"     je ne voudrais pas tomber sur moi meme et causer un" + '\n' +
			"                             paradoxe."
		) ;
		title.color = 0xFFFFFF ;
		title.size = 10 ;
		title.x = Math.round((HXP.screen.width - title.width) / 2) ;
		title.y = 30 ;
		add(title) ;

		//var t = new VarTween( null, Looping ) ;
		//t.tween( continueLabel, "alpha", 0, 100, Ease.sineInOut ) ;
		//this.addTween( t ) ;
		//t.start() ;

	}
	
	override public function update()
	{
		if( Input.pressed(com.haxepunk.utils.Key.ANY) )
			HXP.scene = new GameWorld();
		super.update();
	}
	
	override public function end()
	{
		removeAll();
		super.end();
	}
	
}