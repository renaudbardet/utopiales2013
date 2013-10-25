package tools.localization;
import haxe.macro.Context;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.Assets;

/**
 * A container for all the teanslations, used by the Localization class.
 * @author Samuel Bouchet
 */
class Lang 
{
	public static var keys:Map<String,String> = new Map<String,String>();
	
	private var _translations:Map<String,Translation>;
	
	private var pluralInterp:Interp;
	private var pluralFunction:Expr;
	private var _pluralScript:String;

	/**
	 * @param	translations 	List of translations
	 * @param	pluralScript			Script to calculate the plural form
	 */
	public function new(pluralScript:String) 
	{
		_translations = new Map<String,Translation>();
		_pluralScript = pluralScript;
		
		var parser = new Parser();
		pluralFunction = parser.parseString(pluralScript);
		pluralInterp = new Interp();
	}
	
	public function addTranslation(key:String, translation:Translation):Void {
		
		// record translation
		_translations.set(key, translation);
		
		// record id to have autocompletion on key list
		keys.set(key, key);
	}
	
	/**
	 * Return the plural form to use considering there are "count" objects.
	 * @param	count	Number of object
	 * @return	the plural form to use
	 */
	public function getPlural(count:Int):Int {
		pluralInterp.variables.set("n", count);
		var plural:Int = 0;
		try 
		{
			plural = cast(pluralInterp.execute(pluralFunction), Int);
		}catch (err:Error)
		{
			throw "pluralForm script is not correct. Please use \"n\" as count variable and return an Int (i.e.: pluralForm=\"(n!=1)?1:0\"). Script : "+_pluralScript;
		}
		return plural;
	}
	
	private function get_translations():Map<String,Translation> 
	{
		return _translations;
	}
	public var translations(get_translations, null):Map<String,Translation>;
	
}