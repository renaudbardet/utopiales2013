package tools.attributes;
import flash.errors.Error;

/**
 * An AttributeSet that can equip Item's and calculate new attributes values
 * based on base values and item bonus values.
 * Item itself is an AttributeSet and can equip Items.
 * @author Samuel Bouchet
 */
class AttributeSet{
	
	static private var emptyAttributeSet:AttributeSet = new AttributeSet();
	
	private var _baseAttributes:Map<String,Attribute>;
	private var _usedItems:Map<String,Item>;
	
	private var _priorityLevels:Array<Int>;
	
	/**
	 * Create an AttributeSet that can equip Item's and calculate new attributes values
	 * based on base values and item bonus values.
	 * Item itself is an AttributeSet and can equip Items.
	 */
	public function new() {
		_baseAttributes = new Map<String,Attribute>();
		_usedItems = new Map<String,Item>();
		_priorityLevels = new Array<Int>();
	}
	
	public function toString() {
		var str:String = "";
		
		str += "Items Equiped :\n";
		for (s in _usedItems) {
			str += s.toString();
		}
		str += "Attributes Values :\n";
		for (s in baseAttributes) {
			str += s.toString();
		}
		return str;
	}
	
	/**
	 * Equip item and consider his bonuses when calculating this AttributeSet values.
	 * The same Item can't be equiped on 2 AttributeSet at once.
	 * @param item 			The item to equip
	 * @param refresh 	true to recalculate immediatly the AttributeSet. False if you plan to recalculate it manually later.
	 * @return true if correctly equiped, or false if the item was already equiped on an other AttributeSet
	 */
	public function equip(item:Item, refresh:Bool = true):Bool {
		if (item.equipedOn == null) {
			_usedItems.set(item.name, item);
			item.equipedOn = this;
			if (refresh) this.refresh();
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Unequip item and stop using his bonuses when calculating this AttributeSet values.
	 * @param item 			The item to unequip
	 * @param refresh 	true to recalculate immediatly the AttributeSet. False if you plan to recalculate it manually later.
	 * @return false if the item was not hold by this AttributeSet.
	 */
	public function unequip(item:Item, refresh:Bool = true) :Bool{
		if (item.equipedOn == this) {
			_usedItems.remove(item.name);
			if (refresh) this.refresh();
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Use the object using context information to modify target
	 * @param	context		Anything from your game
	 * @param	target		Anything from your game
	 */
	public function useItems(context:Dynamic, target:Dynamic) {
		for (i in items) {
			i.use(context, target);
			// TODO : apply effects by priority regardless of the item they are on.
		}
	}
	
	/**
	 * Check whether an item is equiped or not by objectName.
	 * @param	itemName
	 */
	public function hasItem(itemName:String) {
		return _usedItems.get(itemName) != null;
	}

	// get (or create) a Attribute in the Attributes subsystem
	public function get(AttributeName:String):Attribute{
		var att:Attribute = _baseAttributes.get(AttributeName);
		if(att == null){
			att = new Attribute(AttributeName);
			_baseAttributes.set(AttributeName, att);
		}
		return att;
	}
	
	/**
	 * Recalculate every attributes using all equiped Items.
	 */
	public function refresh() {
		recalculate();
	}
	
	/**
	 * Recursively recalculate all the system. The logic is here.
	 */
	private function recalculate(){
		// give attributes every bonus object of each item equipped
		refreshAttributesBonusList();
		// next step is to calculate this bonuses values by priority at this item level only
		// sub Items bonuses will be calculated after item base value are refreshed
		refreshBonusValues();
		// now we can calculate items baseValues (it's sum of their bonus) and subItems bonus
		// recursively call refresh function
		refreshItems();
		// now every bonuses are calculated at every level.
		// we just have to add items attributes values to this attributes values
		for (att in _baseAttributes) {
			att.bonusValue = 0;
		}
		for (i in _usedItems) {
			// reset baseValue to the sum of bonuses of this item bonusList.
			for(att in i.baseAttributes){
				get(att.name).bonusValue += att.value;
				// add bonuses of subitem to keep trace of every bonus
				for (b in att.bonusList) {
					get(att.name).bonusList.add(b);
				}
			}
		}
	}
	
	private function refreshItems():Void
	{
		for (i in _usedItems) {
			i.calculateBaseValues();
			i.recalculate();
		}
	}
	
	private function refreshAttributesBonusList() {
		// clear bonus lists in attributes and reset to 0 bonus values
		clearBonus();
		
		// fill attributes bonuslist with concerned item bonus
		// create an array with priority levels
		_priorityLevels.splice(0, _priorityLevels.length);
		for (item in _usedItems) {
			for (bonus in item.bonusList) {
				// add the bonus priority as a priority to loop in
				if (!Lambda.has(_priorityLevels, bonus.priority)) {
					_priorityLevels.push(bonus.priority);
				}
				// add the bonus to the concerned attribute
				get(bonus.attributeName).bonusList.add(bonus);
			}
		}
	}
	
	private function refreshBonusValues() {
		// loop for each priority level
		_priorityLevels.sort(prioritySort);
		for (priority in _priorityLevels) {
			// Update Bonus, based on attributes base value + lower priority bonus values
			for (att in baseAttributes) {
				for (b in att.bonusList) {
					if (b.priority == priority) {
						b.update(this);
					}
				}
			}
			// update attributes bonusValue based on calculated bonus
			for (att in baseAttributes) {
				for (b in att.bonusList) {
					if (b.priority == priority) {
						att.bonusValue += b.value;
					}
				}
			}
		}
	}
	
	private function prioritySort(p1:Int, p2:Int):Int {
		return p1 - p2;
	}

	/**
	 * Clear all bonus for this attributes and equiped items attributes.
	 */
	private function clearBonus() {
		if (_baseAttributes != null) {
			for(att in _baseAttributes){
				att.clearBonus();
			}
		}
	}
	
	private function get_items():Map<String,Item>
	{
		return _usedItems;
	}
	/**
	 * Items equiped on this AttributeSet
	 */
	public var items(get_items, null):Map<String,Item>;
	
	private function get_baseAttributes():Map<String,Attribute>
	{
		return _baseAttributes;
	}
	/**
	 * Attributes base of this AttributeSet (collection of Attribute name=>Attribute object)
	 */
	public var baseAttributes(get_baseAttributes, null):Map<String,Attribute>;
}