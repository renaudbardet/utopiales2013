package com.matttuttle.localization;

import haxe.xml.Fast;

/**
 * A container for all the translations, used by the Localization class.
 * @author Samuel Bouchet
 */
class Language
{

	public var langCode(default, null):String;

	/**
	 * @param	translations 	List of translations
	 * @param	plural			Script to calculate the plural form
	 */
	public function new(lang:Xml)
	{
		translations = new Map<String,Translation>();
		var xml = new Fast(lang);
		var translationNode = xml.node.translation;

		langCode = translationNode.att.lang.substr(0, 2);
		// for each translation
		for (nodeElem in translationNode.nodes.s)
		{
			// record translation
			translations.set(nodeElem.att.id, new Translation(nodeElem));
		}
	}

	public inline function getTranslation(key:String):Translation
	{
		if (translations.exists(key))
			return translations.get(key);
		else
			return null;
	}

	/**
	 * Gets the plural form for languages
	 * All languages at http://unicode.org/repos/cldr-tmp/trunk/diff/supplemental/language_plural_rules.html
	 */
	public function pluralForm(n:Int):Int
	{
		switch (langCode)
		{
			case "af": // afrikaans
				return n == 1 ? 1 : 2;
			case "ar": // arabic
				if (n < 3) return n; // 0, 1, 2
				if (n % 100 >= 3 && n % 100 <= 10) return 3;
				if (n % 100 >= 11 && n % 100 <= 99) return 4;
				return 5;
			case "cs": // czech
				if (n % 100 == 1) return 1;
				if (n % 100 >= 2 && n % 100 <= 4) return 2;
				return 3;
			case "en": // english
				return n == 1 ? 1 : 2;
			case "es": // spanish
				return n == 1 ? 1 : 2;
			case "fr": // french
				return n < 2 ? 1 : 2;
			case "ga": // irish
				return  (n == 1 ? 1 : (n == 2 ? 2 : 3));
			case "lv": // latvian
				if (n % 10 == 1 && n % 100 != 11) return 1;
				if (n != 0) return 2;
				return 3;
			case "lt": // lithuanian
				if (n % 10 == 1 && n % 100 != 11) return 1;
				if (n % 100 != 12 && n % 10 == 2) return 2;
				return 3;
			case "mk": // macedonian
				if (n % 10 == 1) return 1;
				if (n % 10 == 2) return 2;
				return 3;
			case "pl": // polish
				if (n == 1) return 1;
				if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 > 20)) return 2;
				return 3;
			case "ro": // romanian
				if (n == 1) return 1;
				if (n == 0 || (n % 100 >= 1 && n % 100 <= 20)) return 2;
				return 3;
			case "ru": // russian
				if (n % 10 == 1 && n % 100 != 11) return 1;
				if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 > 20)) return 2;
				return 3;
			case "sk": // slovak
				if (n == 1) return 1;
				if (n >= 2 && n <= 4) return 2;
				return 3;
			case "ja":
				return 1;
		}
		return -1;
	}

	private var translations:Map<String,Translation>;

}