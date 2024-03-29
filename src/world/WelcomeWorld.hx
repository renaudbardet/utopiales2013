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
	var _music:Sfx;
	
	public static var instance:WelcomeWorld ;
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

		var continueLabel = new Label("Appuyez sur une touche pour commencer") ;
		continueLabel.color = 0xFFFFFF ;
		continueLabel.size = 16 ;
		continueLabel.x = Math.round((HXP.screen.width - continueLabel.width) / 2);
		continueLabel.y = Math.round(HXP.screen.height - continueLabel.height - 10);
		continueLabel.shadowColor = 0x000000;
		continueLabel.font = Assets.getFont("font/lythgame.ttf").fontName;
		add(continueLabel) ;

		var muteLabel = new Label("M = musique ON/OFF") ;
		muteLabel.color = 0x000000 ;
		muteLabel.size = 8 ;
		muteLabel.x = Math.round((HXP.screen.width - muteLabel.width) - 10);
		muteLabel.y = 10 ;
		muteLabel.font = Assets.getFont("font/lythgame.ttf").fontName;
		add(muteLabel) ;

		var t = new VarTween( null, Looping ) ;
		t.tween( continueLabel, "alpha", 0, 100, Ease.sineInOut ) ;
		this.addTween( t ) ;
		t.start() ;

		music = new Sfx("music/MenuMusicCroped.mp3");
		music.loop(0.2);
	}
	
	override public function update()
	{
		if( Input.pressed(com.haxepunk.utils.Key.ANY) )
			HXP.scene = new Story();
		super.update();
	}
	
	override public function end()
	{
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
	
	function get_music():Sfx
	{
		return _music;
	}
	
	function set_music(value:Sfx):Sfx
	{
		return _music = value;
	}
	
	public var music(get_music, set_music):Sfx;
	
}