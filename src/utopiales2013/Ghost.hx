package utopiales2013;
import com.haxepunk.masks.Hitbox;

/**
 * ...
 * @author Lythom
 */
class Ghost extends Hero
{
	private var _vision:Hitbox;
	private var _detectionDistance:Int;
	private var _moveSpanX:Float;
	private var _moveSpanY:Float;
	
	public function new(detectionDistance:Int, moveSpanX:Float, moveSpanY:Float)
	{
		_detectionDistance = detectionDistance;
		_moveSpanX = moveSpanX;
		_moveSpanY = moveSpanY;
		vision = new Hitbox();
		super();
	}
	
	override public function update():Void
	{
		super.update();
		
		var centerX = x + _moveSpanX / 2;
		var centerY = y + _moveSpanY / 2;
		//vision.height = 1 * this.directionPoint.x;
	}
	
	function get_vision():Hitbox
	{
		return _vision;
	}
	
	function set_vision(value:Hitbox):Hitbox
	{
		return _vision = value;
	}
	
	public var vision(get_vision, set_vision):Hitbox;
	
	
	
}