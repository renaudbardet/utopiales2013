package com.matttuttle.localization;

/**
 * @author Samuel Bouchet
 */
class Localization
{

	/**
	 * Set the current language file to use.
	 * @param	langFile	path to language file.
	 */
	public static function set(langFile:String = "i10n/en-US/strings.xml")
	{
		// read cache in case the langFile has already been loaded
		if (langs.exists(langFile))
		{
			currentLang = langs.get(langFile);
		}
		else
		{
			// retreive file content and parse it
			var xmlStr:String;
#if nme
			xmlStr = openfl.Assets.getText(langFile);
#else
			xmlStr = sys.io.File.getContent(langFile);
#end
			if (xmlStr != null)
			{
				currentLang = new Language(Xml.parse(xmlStr));
			}
			else
			{
				throw "The lang file does not exists at path \""+langFile+"\".";
			}

			langs.set(langFile, currentLang);
		}

	}

	/**
	 * Get translation of a text in the current language from a key.
	 * @param	key		string id
	 * @param	count	number of elements. Used to know wich singular or plural form has to be choose to translate.
	 * @param	params	parameters to inject into the placeholders of the translated text. Placeholder must be %0, %1, %2, %3, etc.
	 * @return	The translation of a text in the current language from a key.
	 */
	public static function translate(key:String, params:Array<String> = null, count:Int = 1):String
	{
		// get translation for the key
		var translation:Translation = currentLang.getTranslation(key);
		if (translation == null)
			throw "Could not find translation " + key;

		// get plural form (0=singular, >0=plural form id)
		var string = translation.getString(currentLang.pluralForm(count));
		if (params != null && string != null)
		{
			for (i in 0...params.length)
			{
				string = StringTools.replace(string, "{" + i + "}", params[i]);
			}
		}
		return string;
	}

	private static var currentLang:Language;
	private static var langs:Map<String,Language> = new Map<String,Language>();

}