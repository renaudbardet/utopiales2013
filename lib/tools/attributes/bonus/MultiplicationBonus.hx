package tools.attributes.bonus;
import tools.attributes.AttributeSet;
import tools.attributes.Bonus;

/**
 * ...
 * @author Samuel Bouchet
 */
class MultiplicationBonus extends Bonus
{
	private var _multiple:Float ;
	
	/**
	 * Bonus that add a multiple of an Attribute final value on the top of the final value.
	 * @param	attributeName	the Attribute to alter
	 * @param	multiple		the multiplicator to add (ie: 0.05 for +5% of the final value)
	 * @param   priority		bonus with lower priority value are taken into account to calculate bonus with higher priority value.
	 * @param	label			(optional)label of this particular property
	 */
	public function new(attributeName:String, multiple:Float, priority:Int, label:String=null) 
	{
		super(attributeName, multiplyValue, priority, label);
		_multiple = multiple;
	}
	
	private function multiplyValue(attributes:AttributeSet, bonus:Bonus):Float{
		return attributes.get(attributeName).value * _multiple;
	}
}