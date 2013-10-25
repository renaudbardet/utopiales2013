package tools.attributes;

/**
 * One attribute of an AttributeSet.
 * An attribute hold his bonus (list calculated by AttributSet).
 * @author Samuel Bouchet
 */
class Attribute
{
	private var _baseValue:Float;
	
	// bonus is recalculated each time a Bonus is added or removed to AttributeSet parent object
	private var _bonusValue:Float;
	
	// list of all the Bonusfrom all the items giving alterations to this Attribute.
	private var _bonusList:List<Bonus>;
	
	// base + all bonus is recalculated each time the base or the bonus is changed
	private var _value:Float;
	
	private var _name:String;

	public function new(name:String){
		_name = name;
		_value = 0;
		_bonusValue = 0;
		_baseValue = 0;
		bonusList = new List<Bonus>();
	}
	
	public function toString():String {
		var str = "\t" + name + " (base+bonus)) : " + ((value>0) ? "+":"") + value + " (" + baseValue +" + " + bonusValue + ")\n";
		var bonusSum:Float = 0;
		for (m in bonusList) {
			str += "\t\t" + ((m.value>0) ? "+":"") + m.value + " by "
				+ ((m.item != null) ? m.item.name:"")
				+ ((Std.is(m.item.equipedOn, Item)) ? " on "+cast(m.item.equipedOn, Item).name:"")
				+ ((m.label != null)?" (" + m.label + ")":"") +"\n";
			bonusSum += m.value;
		}
		return str;
	}
	
	public function clearBonus() {
		_bonusList.clear();
		_bonusValue = 0;
		_value = _baseValue;
		
	}

	private function updateValue()
	{
		_value = _bonusValue + _baseValue;
	}
	
	// ACCESSORS
	
	private function get_bonusValue():Float
	{
		return _bonusValue;
	}
	private function set_bonusValue(value:Float):Float
	{
		_bonusValue = value;
		updateValue();
		return _bonusValue;
	}
	/**
	 * Sum of the bonus values granted by equiped items.
	 * Read bonusList to have details of this bonus calculation.
	 */
	public var bonusValue(get_bonusValue, set_bonusValue):Float;
	
	// name R
	private function get_name():String
	{
		return _name;
	}
	/**
	 * Attribute name.
	 */
	public var name(get_name, null):String;
	
	// bonus list R
	private function get_bonusList():List<Bonus>
	{
		return _bonusList;
	}
	private function set_bonusList(value:List<Bonus>):List<Bonus>
	{
		return _bonusList = value;
	}
	/**
	 * Automatically filled to contain every bonus applied on this attribute.
	 * Read this list to understand the details of the final value calculation.
	 */
	public var bonusList(get_bonusList, set_bonusList):List<Bonus>;
	
	// Base RW
	private function get_baseValue():Float
	{
		return _baseValue;
	}
	private function set_baseValue(value:Float):Float
	{
		_baseValue = value;
		updateValue();
		return _baseValue;
	}
	/**
	 * Base value of the AttributeSet.
	 * For any basic AttributeSet, base value can freely be set by user to define base attribute value.
	 * For an Item, base value is automatically set to the sum of the declared bonuses.
	 */
	public var baseValue(get_baseValue, set_baseValue):Float;
	
	// Value R
	private function get_value():Float
	{
		return _value;
	}
	/**
	 * Final auto calculated value, equals to baseValue + bonusValue.
	 * To define an initial value, set "baseValue" instead.
	 */
	public var value(get_value, null):Float;
	
}