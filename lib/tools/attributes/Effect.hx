package tools.attributes;

/**
 * This bonus does not modify attributes but keep trace of particular properties.
 * i.e. slow, stun, poisonning, etc.
 * @author Samuel Bouchet
 */
class Effect
{
	private var proc:Dynamic -> Dynamic -> Bool;
	private var label:String;
	private var priority:Int;
	
	public var item:Item;

	public function new(effectFunction:Dynamic->Dynamic->Bool, priority:Int=0, effectLabel:String=null) 
	{
		this.priority = priority;
		this.proc = effectFunction;
		this.label = effectLabel;
		this.item = null;
	}
	
	public function toString(parentItem:Item=null) {
		var str = "";
		if (item != parentItem && item != null) {
			str += "[" + item.name + "] ";
		}
		str += ((label != null)?" ("+label+")":"") ;
		return str;
	}
	
	public function applyEffect(context:Dynamic, target:Dynamic):Bool {
		if (proc != null) {
			return proc(context, target);
		}
		return false;
	}
	public static function sort(e1:Effect, e2:Effect):Int {
		return e1.priority - e2.priority;
	}
}