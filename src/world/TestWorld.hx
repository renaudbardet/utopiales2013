package world;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Scene;
import flash.Lib;

/**
 * ...
 * @author Samuel Bouchet
 */

class TestWorld extends Scene
{
	public static var instance:Scene ;

	public function new()
	{
		super();
	
		var t:Float = Lib.getTimer();
		
		for (i in 0...100000) {
			//Std.int(1.254); // 13ms
			//Math.floor(1.254); // >21ms
			//Math.ceil(1.254); // >21ms
			//Math.min(5, 6); // 22ms
			//(5 < 6)?5:6; // 13ms;
		}
		
		var t2:Float = Lib.getTimer();
		trace(t2 - t + " ms.");
		
		
		
		instance = this;
	}

	override public function update()
	{
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
		
		super.update();
	}
	
	override public function render()
	{
		super.render();
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