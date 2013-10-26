package utopiales2013;
import com.haxepunk.masks.Hitbox;

/**
 * ...
 * @author Lythom
 */
class Ghost extends Hero
{
	private var _vision:Vision;
	
	
	public function new(detectionDistance:Int, moveSpanX:Float, moveSpanY:Float)
	{
		vision = new Vision(this, detectionDistance, moveSpanX, moveSpanY);
		super();
	}
	
	override public function update():Void
	{
		super.update();
	}
	
	function get_vision():Vision
	{
		return _vision;
	}
	
	function set_vision(value:Vision):Vision
	{
		return _vision = value;
	}
	
	public var vision(get_vision, set_vision):Vision;
	
	
	
}