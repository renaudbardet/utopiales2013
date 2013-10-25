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
class RpgHero extends BasicPhysicsEntity
{
	private var facteur:Float;

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
	}
	
	override public function added():Void
	{
		super.added();
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
		maxVelocity.x = 150 * facteur;
		maxVelocity.y = 150 * facteur;

		if (Input.check("left")) {
			this.acceleration.x = - xAcc * facteur;
			friction.x = 0;
		} else if (Input.check("right")) {
			this.acceleration.x = xAcc * facteur;
			friction.x = 0;
		} else {
			this.acceleration.x = 0;
			velocity.x = velocity.x * (1 - 0.3);
		}
		
		if (Input.check("up")) {
			this.acceleration.y = - yAcc * facteur;
			friction.y = 0;
		} else if (Input.check("down")) {
			this.acceleration.y = yAcc * facteur;
			friction.y = 0;
		}else {
			this.acceleration.y = 0;
			velocity.y = velocity.y * (1 - 0.3);
		}
		
		super.update();
	}
}