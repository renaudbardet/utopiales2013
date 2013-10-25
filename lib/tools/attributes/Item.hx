package tools.attributes;
import tools.attributes.bonus.AdditionBonus;
import tools.attributes.bonus.MultiplicationBonus;

/**
 * An Item is a bonusList holder that can be equiped on an AttributeSet.
 * The AttributeSet is automatically granted with the Item bonuses.
 * Item itself is a AttributeSet, its baseAttributes property is automatically calculated to equals the total bonus granted.
 * Don't try to set values manually but use the "add"s functions to add bonuses.
 * @author Samuel Bouchet
 */
class Item extends AttributeSet {
	
	private var _name:String;
	private var _label:String;
	private var _equipedOn:AttributeSet;
	
	/**
	 * Bonuses granted by this Item.
	 * Don't modify it directly, use adds/remove/has functions to interact
	 */
	public var bonusList:List<Bonus>;
	
	/**
	 * Effects granted by this Item.
	 * Don't modify it directly, use addEffect/removeEffect/hasEffect functions to interact
	 */
	public var effectList:Array<Effect>;
	
	/**
	 * An Item is a bonusList holder that can be equiped on an AttributeSet.
	 * The AttributeSet is automatically granted with the Item bonuses when AttributeSet.refresh() is called.
	 * Item base attributes are automatically calculated, don't try to set their values manually but use the "add"s functions.
	 * @param	name	Item unique name or id. You won't be able to equip Item with the same name on the same AttributeSet.
	 */
	public function new(name:String) {
		super();
		_name = name;
		_equipedOn = null;
		bonusList = new List<Bonus>();
		effectList = new Array<Effect>();
	}
	
	/**
	 * Display the item name and bonuses
	 * @return
	 */
	override public function toString():String {
		var str = "\t" + name + " :\n";
		str += "\t    Bonus list\n";
		// bonuses granted by this item directly
		for(m in bonusList){
			str += "\t\t" + m.toString() + "\n";
		}
		// bonuses granted by sub items (are applied on item base stats)
		for (att in baseAttributes) {
			for (m in att.bonusList) {
				str +=  "\t\t" 
					+ ((this != m.item && m.item != null) ? "[" + m.item.printParentsUntil(this) + "] " : "")
					+ m.toString() 
					+ "\n";
			}
		}
		str += "\t    Bonus values\n";
		for (s in baseAttributes) {
			str += "\t\t"+ s.name + ": " + s.value+"\n";
		}
		if (effectList.length>0) str += "\t    Effects list\n";
		for(e in effectList){
			str +=  "\t\t" + e.toString(this) + "\n";
		}
		return str;
	}

	private function printParentsUntil(until:Item):String {
		var str:String = "";
		var item:Item = this;
		var sep:String = "";
		while (item != null && item != until) {
			str += sep + item.name;
			item = (Std.is(item.equipedOn, Item) ? cast(item.equipedOn, Item) : null);
			sep = " > ";
		}
		return str;
	}
	
	/**
	 * Recalculate every attributes using all equiped Items.
	 * This function can be called automatically when an object is equiped or unequiped to refresh all the data.
	 */
	override public function refresh() {
		if (_equipedOn != null) {
			//call refresh to the top parent. Recalculate is then recursive.
			_equipedOn.refresh();
		} else {
			// Occur when a non equiped Item is calculated. Called once at item creation.
			// Populate the Item _baseAttributes with empty values.
			super.recalculate();
		}
	}
	
	/**
	 * recalculate the base values of the item.
	 */
	public function calculateBaseValues() {
		// reset baseValue to the sum of bonuses of this item bonusList. (! Different than the bonuses granted by sub-items !)
		for(att in baseAttributes){
			att.baseValue = 0;
		}
		for (b in bonusList) {
			get(b.attributeName).baseValue += b.value;
		}
	}
	
	/**
	 * Recalculate base values as if this Item were equiped on the provided AttributeSet.
	 * After calling this method, use "get(attributeName).value" to read to bonus that would be provided by this item
	 * if equiped or loop throw "baseAttributes" property. Sub items equiped on this item will be taken into account.
	 * Item must be unequiped. Otherwise, return false and do nothing.
	 * @param	attributes The attributeSet to test this Item on. Use AttributeSet.emptyAttributeSet if null.
	 */
	public function simulateOn(attributes:AttributeSet=null):Bool {
		if (this._equipedOn != null) return false;
		
		if (attributes == null) {
			attributes = AttributeSet.emptyAttributeSet;
		}
		
		attributes.equip(this);
		attributes.unequip(this);
		return true;
	}
	
	/**
	 * Use the object using context information to modify target
	 * @param	context		Anything from your game
	 * @param	target		Anything from your game
	 */
	public function use(context:Dynamic, target:Dynamic) {
		for (i in 0...effectList.length) {
			var e:Effect = effectList[i];
			e.applyEffect(context, target);
		}
	}
	
	/**
	 * add a custom Effect to Item
	 * @param	bonus the bonus to add
	 */
	public function addEffect(effect:Effect):Bool {
		if (effect.item == null) {
			effectList.push(effect);
			effect.item = this;
			effectList.sort(Effect.sort);
			return true;
		} else {
			// this bonus is already present on another Item. Can't be used twice.
			return false;
		}
	}
	
	/**
	 * check if the Item has the named Bonus
	 * @param	bonus	bonus to test
	 * @return 	true if the Item has the named Bonus
	 */
	public function hasEffect(effect:Effect):Bool {
		return Lambda.has(effectList, effect);
	}
	
	/**
	 * remove a Bonus to alter Attributes. return true if the Bonus has been found.
	 * @param	bonus	Bonus to remove
	 * @return	have the bonus been correctly removed ? false if the bonus were not in the bonusList.
	 */
	public function removeEffect(effect:Effect):Bool {
		if (effect.item == this) {
			effect.item = null;
			effectList.remove(effect);
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * add a custom Bonus to Item
	 * @param	bonus the bonus to add
	 */
	public function add(bonus:Bonus):Bool {
		if (bonus.item == null) {
			bonusList.add(bonus);
			bonus.item = this;
			calculateBaseValues();
			return true;
		} else {
			// this bonus is already present on another Item. Can't be used twice.
			return false;
		}
	}
	
	/**
	 * Bonus that add a fixed value.
	 * @param	attributeName	the Attribute to alter
	 * @param	value			the amount to add (can be nagative to substract)
	 * @param   priority		bonus with lower priority value are taken into account to calculate bonus with higher priority value.
	 * @param	label			(optional)label of this particular property
	 */
	public function addAdditionBonus(attributeName:String, value:Float, priority:Int=0, label:String=null):Void {
		add(new AdditionBonus(attributeName, value, priority, label));
	}
	
	/**
	 * Bonus that add a multiple of an Attribute final value on the top of the final value.
	 * @param	attributeName	the Attribute to alter
	 * @param	multiple		the multiplicator to add (ie: 0.05 for +5% of the final value)
	 * @param   priority		bonus with lower priority value are taken into account to calculate bonus with higher priority value.
	 * @param	label			(optional)label of this particular property
	 */
	public function addMultiplicationBonus(attributeName:String, multiple:Float, priority:Int=0, label:String=null):Void {
		add(new MultiplicationBonus(attributeName, multiple, priority, label));
	}
	
	/**
	 * check if the Item has the named Bonus
	 * @param	bonus	bonus to test
	 * @return 	true if the Item has the named Bonus
	 */
	public function has(bonus:Bonus):Bool {
		return Lambda.has(bonusList, bonus);
	}
	
	/**
	 * remove a Bonus to alter Attributes. return true if the Bonus has been found.
	 * @param	bonus	Bonus to remove
	 * @return	have the bonus been correctly removed ? false if the bonus were not in the bonusList.
	 */
	public function remove(bonus:Bonus):Bool {
		if (bonus.item == this) {
			bonus.item = null;
			bonusList.remove(bonus);
			calculateBaseValues();
			return true;
		} else {
			return false;
		}
	}
	

	// ACCESSORS
	private function get_equipedOn():AttributeSet
	{
		return _equipedOn;
	}
	
	private function set_equipedOn(value:AttributeSet):AttributeSet
	{
		return _equipedOn = value;
	}
	/**
	 * AttributeSet on wich the item is equiped. null if not equiped.
	 */
	public var equipedOn(get_equipedOn, set_equipedOn):AttributeSet;
	private function get_name():String
	{
		return _name;
	}
	/**
	 * Item unique name or id. You won't be able to equip Item with the same name on the same AttributeSet.
	 */
	public var name(get_name, null):String;
	
}