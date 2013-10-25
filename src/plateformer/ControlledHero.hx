package plateformer;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.plateformer.BasicPhysicsEntity;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.display.BitmapData;
import flash.geom.Point;

/**
 * ...
 * @author Lythom
 */
class ControlledHero extends BasicPhysicsEntity
{
	private var facteur:Float;
	private var gravity:Point;

	public function new(x:Int=0, y:Int=0) 
	{
		super(x,y);
		var bmpPerso:BitmapData = new BitmapData(10, 25, false, 0x00FFFF);
		var graphicPerso:Image = new Image(bmpPerso);
		set_graphic(graphicPerso);
		graphicPerso.x = 0;
		graphicPerso.y = 0;
		setHitbox(bmpPerso.width - 1, bmpPerso.height - 1);
		
		maxVelocity.x = 200;
		
		// 20 px = 1m
		gravity = new Point(0, (9.81)*20);
	}
	
	override public function added():Void 
	{
		super.added();
		this.forces.push(gravity);
	}
	
	
	override public function update():Void 
	{
		this.acceleration.normalize(0);
		var xAcc:Float = 700;
		var yAcc:Float = 700;
		
		if (Input.check(Key.SHIFT)){
			facteur = 2;
		} else {
			facteur = 1;
		}
		maxVelocity.x = 150*facteur;
		
		if (Input.check(Key.UP) && onGround)
		{
			this.acceleration.y = -200/HXP.elapsed;
		}
		
		if (Input.check(Key.LEFT))
		{
			this.acceleration.x = - xAcc * facteur;
			friction.x = 0;
		} else if (Input.check(Key.RIGHT)) {
			this.acceleration.x = xAcc * facteur;
			friction.x = 0;
		} else {
			this.acceleration.x = 0;
			friction.x = 0.3;
		}
		
		if (Input.pressed(Key.NUMPAD_ADD))
		{
			gravity.y ++ ;
			trace(gravity.y);
		}
		
		if (Input.pressed(Key.NUMPAD_SUBTRACT))
		{
			gravity.y -- ;
			trace(gravity.y);
		}
		
		if (this.y > 480) {
			this.x = 100;
			this.y = 0;
		}
		
		super.update();
	}
}