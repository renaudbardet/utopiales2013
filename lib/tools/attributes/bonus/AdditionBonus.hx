package tools.attributes.bonus;
import tools.attributes.AttributeSet;
import tools.attributes.Bonus;

/**
 * ...
 * @author Samuel Bouchet
 */

class AdditionBonus extends Bonus
{
	
	/**
	 * Bonus that add a fixed value.
	 * @param	attributeName	the Attribute to alter
	 * @param	value			the amount to add (can be nagative to substract)
	 * @param   priority		bonus with lower priority value are taken into account to calculate bonus with higher priority value.
	 * @param	label			(optional)label of this particular property
	 */
	public function new(attributeName:String, value:Float, priority:Int, label:String=null) 
	{
		super(attributeName, null, priority, label);
		this.value = value;
	}
}