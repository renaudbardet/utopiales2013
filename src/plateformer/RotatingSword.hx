package plateformer;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.display.BitmapData;

/**
 * ...
 * @author Samuel Bouchet
 */

class RotatingSword extends Entity
{
	private var graphicImg:Image;
	/**
	 * In turn per second
	 */
	private var _rotationSpeed:Float;
	private var _distance:Float;
	private var _hero:Entity;

	public function new(hero:Entity) 
	{
		super();
		
		_hero = hero;
		var bmp:BitmapData = new BitmapData(20, 3, false, 0xB4494D);
		graphicImg = new Image(bmp);
		graphicImg.originX = 0;
		graphicImg.originY = 2;
		graphic = graphicImg;
		
		rotationSpeed = -2;
		_distance = 5;
	}
	
	override public function update():Void 
	{
		if (Input.mouseReleased) {
			rotationSpeed = -rotationSpeed;
		}
		
		if (Input.pressed(Key.NUMPAD_0)) {
			rotationSpeed = 0;
		}
		
		if (Input.pressed(Key.NUMPAD_1)) {
			rotationSpeed = 0.5;
		}
		
		if (Input.pressed(Key.NUMPAD_2)) {
			rotationSpeed = 1;
		}
		
		super.update();
	}
	
	public function updatePosition():Void 
	{
		this.graphicImg.angle += (360 * rotationSpeed) * HXP.elapsed;
		this.x = _hero.x + _hero.halfWidth + _distance * Math.cos((this.graphicImg.angle*Math.PI*2)/360);
		this.y = _hero.y + _hero.halfHeight - _distance * Math.sin((this.graphicImg.angle*Math.PI*2)/360);
	}
	
	private function get_rotationSpeed():Float 
	{
		return _rotationSpeed;
	}
	private function set_rotationSpeed(value:Float):Float 
	{
		return _rotationSpeed = value;
	}
	
	public var rotationSpeed(get_rotationSpeed, set_rotationSpeed):Float;
	
	private function get_distance():Float 
	{
		return _distance;
	}
	
	private function set_distance(value:Float):Float 
	{
		return _distance = value;
	}
	
	public var distance(get_distance, set_distance):Float;
	
}