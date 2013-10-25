package world;
import com.haxepunk.gui.Label;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Scene;
import tools.localization.Localization;

/**
 * ...
 * @author Samuel Bouchet
 */

class TranslationTestWorld extends Scene
{
	public static var instance:Scene ;
	
	// shortcut
	public static var _ = Localization.translate;

	public function new()
	{
		super();

		var str = "";
		var langs = ["lang/en.xml", "lang/fr-FR.xml"];
		
		var line:String = "-";
		for (i in 0...20) {
			line += "-";
		}
		
		Label.defaultColor = 0xFFFFFF;
		
		var decal:Int = 0;
		for (l in langs) {
			str += l + "\n";
			
			Localization.set(l);
			var keys = Localization.keys;

			for (qtt in 0...5) {
				var apple = _(keys.apple, qtt);
				var test = _(keys.test, qtt);
				var sentence = _(keys.thereis, qtt, [apple, Std.string(qtt)]);
				str += sentence + "\n";
				sentence = _(keys.thereis, qtt, [test, Std.string(qtt)]);
				str += sentence + "\n";
			}
			str += _("je n'existe pas", 5, ["5"])+ "\n";
			add(new Label(str, 20+decal, 20));
			str = "";
			decal += 150;
		}
		
		instance = this;
	}
	
	override public function update()
	{
		super.update();
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
	}
	
	override public function begin()
	{
		super.begin();
	}
	
	override public function end()
	{
		super.end();
	}
	
}