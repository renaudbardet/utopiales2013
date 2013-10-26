package utopiales2013;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Text;

/**
 * ...
 * @author Lythom
 */
class Chrono extends Entity
{
	var _text:Text;

	public function new()
	{
		_text = new Text("");
		super();
	}
	
	function get_text():String
	{
		return _text.text;
	}
	
	function set_text(value:String):String
	{
		return _text.text = value;
	}
	
	public var text(get_text, set_text):String;
	
}