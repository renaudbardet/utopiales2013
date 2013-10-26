package world;
import com.haxepunk.gui.Button;
import com.haxepunk.gui.CheckBox;
import com.haxepunk.gui.Control;
import com.haxepunk.gui.Label;
import com.haxepunk.gui.RadioButton;
import com.haxepunk.HXP;
import com.haxepunk.Scene;

/**
 * ...
 * @author Samuel Bouchet
 */

class WelcomeWorld extends Scene
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
		initHaxePunkGui("gfx/ui/greyDefault.png");
	}
	
	override public function update()
	{
		HXP.scene = new GameWorld();
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
			Control.defaultLayer = 100;
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
			Label.defaultFont = openfl.Assets.getFont("font/pf_ronda_seven.ttf");
			// Label defaultColor. Tip inFlashDevelop : use ctrl + shift + k to pick a color.
			Label.defaultColor = 0x102945;
			// Label default Size.
			Label.defaultSize = 8;
			
			WelcomeWorld.guiInitialized = true;
		}
	}
	
}