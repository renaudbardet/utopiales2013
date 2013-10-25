package tools.localization;
import haxe.io.Error;
import haxe.xml.Fast;
import openfl.Assets;

/**
 * ...
 * @author Samuel Bouchet
 */
class Localization 
{
	private static var langs:Map<String,Lang> = new Map<String,Lang>();
	private static var currentLang:Lang = null;
	private static var _keys:Translations = new Translations(Lang.keys.get);
	
	private static var defaultLanguagePath:String = "lang/en.xml";
	
	
	/**
	 * Get translation of a text in the current language from a key.
	 * @param	key		string id
	 * @param	count	number of elements. Used to know wich singular or plural form has to be choose to translate.
	 * @param	params	parameters to inject into the placeholders of the translated text. Placeholder must be %0, %1, %2, %3, etc.
	 * @return	The translation of a text in the current language from a key.
	 */
	public static function translate(key:String, count:Int = 1, params:Array<String> = null):String {
		// get translation for the key
		var translation:Translation = currentLang.translations.get(key);
		var pluralForm:Int = currentLang.getPlural(count);
		
		// asked translation does exists in the lang. try in english.
		if (translation == null && langs.exists(defaultLanguagePath)) {
			translation = langs.get(defaultLanguagePath).translations.get(key);
			pluralForm = langs.get(defaultLanguagePath).getPlural(count);
		}
		
		var string = null;
		
		// there is a translation, translate
		if(translation!=null){
			// plural form if at least one exists
			if (pluralForm>0 && translation.plurals.iterator().hasNext()) {
				// get the plural of form "pluralForm" 
				var pluralForm = translation.plurals.get(Std.string(pluralForm));
				if (pluralForm != null) {
					string = pluralForm;
					
				// if this plural form does not exists for this word, fallback on the first plural form
				} else {
					string = translation.plurals.iterator().next();
				}
			}
			// if singular is asked or there is no plural form, fallback on singular
			if (pluralForm == 0 || string == null) {
				string = translation.singular;
			}
			if (params != null && string != null) {
				for (i in 0...params.length) {
					string = StringTools.replace(string, "%" + i, params[i]);
				}
			}
			
		// there is no translation, display the key itself
		} else {
			string = key;
		}
		return string;
	}
	
	/**
	 * Set the current language file to use.
	 * @param	langFile	path to language file.
	 */
	public static function set(langFile:String) {
		// read cache in case the langFile has already been loaded
		if (langs.exists(langFile)) {
			currentLang = langs.get(langFile);
		} else {
			// retreive file content and parse it
			var xmlStr:String = Assets.getText(langFile);
			if (xmlStr != null) {
				
				var xml = new Fast(Xml.parse(xmlStr));
				// create a new lang structure
				currentLang = new Lang(xml.node.translations.att.pluralForm);
				
				// for each translation
				for (nodeElem in xml.node.translations.nodes.t) {
					// list plurals
					var plurals:Map<String,String> = new Map<String,String>();
					for (p in nodeElem.nodes.plural) {
						plurals.set((p.has.form)?p.att.form:"1", p.innerData);
					}
					// record translation
					currentLang.addTranslation(
						nodeElem.att.id,
						new Translation(
							nodeElem.node.singular.innerData,
							plurals
							//,(nodeElem.hasNode.context) ? nodeElem.node.context.innerData : null
						)
					);
				}
			} else {
				throw "The lang file does not exists at path \""+langFile+"\".";
			}
			
			langs.set(langFile, currentLang);
		}
		
	}
	
	private static function get_keys():Translations 
	{
		return _keys;
	}
	/**
	 * Give acces to available keys id with autocompletion, based on en.xml declarations.
	 */
	static public var keys(get_keys, null):Translations;
}