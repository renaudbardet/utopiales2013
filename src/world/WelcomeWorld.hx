package world;
import com.haxepunk.HXP;
import com.haxepunk.Scene;

/**
 * ...
 * @author Samuel Bouchet
 */

class WelcomeWorld extends Scene
{
	
	public static var instance:Scene ;

	public function new()
	{
		super();
	
		instance = this;
	}
	
	override public function begin()
	{
		super.begin();
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
	
}