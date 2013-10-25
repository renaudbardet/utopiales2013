package tools.attributes;
import tools.attributes.Item;

/**
 * A bonus modify one Attribute of an AttributeSet when the Item holding this bonus is equiped on the AttributeSet.
 * A bonus can be added to only one Item. The same fomula can be used for several Bonus.
 * The bonus can be calculated based on data in the AttributeSet, data in the Bonus itseld, or data accessibles from 
 * the context of custom formula.
 * @author Samuel Bouchet
 */
class Bonus {
	/**
	 * item on wich this Bonus is applied.
	 */
	public var item:Item;

	/**
	 * what would be written in the object description
	 */
	public var label:String;
	
	/**
	 * 0 is applied first, heigher values are applied last.
	 */
	public var priority:Int;
	
	/**
	 * Custom formula that will calculate the value of a bonus.
	 * This function will be called each time the AttributeSet is refreshed.
	 *  - This function must return the calculated bonus. This value will be used to increase bonus value of an attribute.
	 *  - to calculate the bonus, you can use :
	 *  	* any data from attributeSet, bonus values from lower priority bonus will have been calculated.
	 *   	  i.e. attributes.get(attName).value is baseValue+bonusValue, bonusValue being the sum of lower priority bonus.
	 *  	* any data from the Bonus (this). Because the function might be declared anywhere, you may have no
	 *        other way to access this object from the function. You can modify the bonus here as well, 
	 * 		  i.e. changing the label depending on the context.
	 *      * any data from the function context. See http://haxe.org/ref/syntax#local-functions for more details.
	 */
	public var formula:AttributeSet->Bonus->Float;
	
	/**
	 * Attribute modified by this bonus
	 */
	public var attributeName:String;
	
	/**
	 * list of the Attributes modified on top of baseValues + raw changes
	 */
	public var value:Float;
	
	/**
	 * Create a new Bonus based on a custom formula. formula is a function that must be implemented and provided 
	 * to the contructor with signature : function(attributes:AttributeSet, bonus:Bonus):Float;
	 *  - This function must return the calculated bonus. This value will be used to increase bonus value of an attribute.
	 *  - to calculate the bonus, you can use :
	 *  	* any data from attributeSet, bonus values from lower priority bonus will have been calculated.
	 *   	  i.e. attributes.get(attName).value is baseValue+bonusValue, bonusValue being the sum of lower priority bonus.
	 *  	* any data from the Bonus (this). Because the function might be declared anywhere, you may have no
	 *        other way to access this object from the function. You can modify the bonus here as well, 
	 * 		  i.e. changing the label depending on the context.
	 *      * any data from the function context. See http://haxe.org/ref/syntax#local-functions for more details.
     *
	 * @param	attributeName	Name of the attribute this bonus modify.
	 * @param	formula			function used to calculate the bonus amount (can be negative to give malus)
	 * @param	priority		bonus with lower priority value are taken into account to calculate bonus with higher priority value.
	 * @param	label
	 */
	public function new(attributeName:String, formula:AttributeSet->Bonus->Float, priority:Int=0, label:String = null) {
		this.label = label;
		this.formula = formula;
		this.attributeName = attributeName;
		this.priority = priority;
		this.value = 0;
	}
	
	/**
	 * call the formula to update/refresh Bonus values.
	 * Automatically called, don't call it yourself.
	 * @param	attributes
	 */
	public function update(attributes:AttributeSet){
		if(formula != null){
			value = formula(attributes, this);
		}
	}
	
	public function toString() {
		// specify item granting this bonus if the one displaying it is not the owner
		var str = "";
		str += attributeName + " : " + ((value > 0) ? "+":"") + value
			+ ((label != null)?" ("+label+")":"") ;
		return str;
	}
}