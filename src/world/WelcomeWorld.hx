package world;
import com.haxepunk.Entity;
import com.haxepunk.Sfx;
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

class WelcomeWorld extends Scene
{
	var music:Sfx;
	
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
		initHaxePunkGui("gfx/ui/greyDefault.png");

		var bg = new Entity() ;
		bg.graphic = new Stamp( Assets.getBitmapData("gfx/accueil.png") ) ;
		add(bg) ;
		bg.layer = 9001 ;

		var title = new Label("Tard is paradox") ;
		title.color = 0xFFFFFF ;
		title.size = 40 ;
		title.x = Math.round((HXP.screen.width - title.width) / 2) ;
		title.y = 30 ;
		add(title) ;

		var continueLabel = new Label("Appuyez sur une touche pour commencer") ;
		continueLabel.color = 0xFFFFFF ;
		continueLabel.size = 20 ;
		continueLabel.x = Math.round((HXP.screen.width - continueLabel.width) / 2) ;
		continueLabel.y = Math.round(HXP.screen.height - 130) ;
		add(continueLabel) ;

		var t = new VarTween( null, Looping ) ;
		t.tween( continueLabel, "alpha", 0, 100, Ease.sineInOut ) ;
		this.addTween( t ) ;
		t.start() ;

		music = new Sfx("music/mainLoop.mp3");
		music.loop(0.4);
	}
	
	override public function update()
	{
		if( Input.pressed(com.haxepunk.utils.Key.ANY) )
			HXP.scene = new Story();
		super.update();
	}
	
	override public function end()
	{
		music.stop();
		removeAll();
		super.end();
	}
	
	private function initHaxePunkGui(skin:String):Void
	{
		// Choose custom skin. Parameter can be a String to resource or a bitmapData.
		Control.useSkin(skin);
		
		if(!WelcomeWorld.guiInitialized){
			// The default layer where every component will be displayed on.
			// Most components use severals layers (at least 1 per component child). A child component layer will be <100.
			Control.defaultLayer = 20;
			// Use this to fit your button skin's borders, set the default padding of every new Button and ToggleButton.
			// padding attribute can be changed on instances after creation.
			Button.defaultPadding = 4;
			// Size in px of the tickBox for CheckBoxes. Default is skin native size : 12.
			CheckBox.defaultBoxSize = 12;
			// Same for RadioButtons.
			RadioButton.defaultBoxSize = 12;
			// Label defaults parameters affect every components that uses labels : Button, ToggleButton, CheckBox, RadioButton, MenuItem, Window Title.
			// Those labels are always accessible using "myComponent.label" and you can change specific Labels apperence any time.
			// Label default font (must be a openfl.text.Font object).
			Label.defaultFont = openfl.Assets.getFont("font/Hardpixel.ttf");
			// Label defaultColor. Tip inFlashDevelop : use ctrl + shift + k to pick a color.
			Label.defaultColor = 0x102945;
			// Label default Size.
			Label.defaultSize = 10;
			
			WelcomeWorld.guiInitialized = true;
		}
	}
	
}