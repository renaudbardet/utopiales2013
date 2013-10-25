package tools.localization;
import openfl.Assets;

/**
 * The singular and plurals translations for one key.
 * @author Samuel Bouchet
 */
class Translation 
{
	private var _singular:String;
	private var _plurals:Map<String,String>;

	/**
	 * 
	 * @param	singular	singular translation
	 * @param	plurals		plural translations
	 */
	public function new(singular:String, plurals:Map<String,String>) 
	{
		_singular = singular;
		_plurals = plurals;
	}
	
	private function get_singular():String 
	{
		return _singular;
	}
	
	private function set_singular(value:String):String 
	{
		return _singular = value;
	}
	
	public var singular(get_singular, set_singular):String;
	
	private function get_plurals():Map<String,String> 
	{
		return _plurals;
	}
	
	private function set_plurals(value:Map<String,String>):Map<String,String> 
	{
		return _plurals = value;
	}
	
	public var plurals(get_plurals, set_plurals):Map<String,String>;
	
}