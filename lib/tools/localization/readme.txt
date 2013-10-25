This library is a tool provided to translate any kind of text in your haxe software.
It does not claim to be a full localization or internationalization tool.

For more information about localization and internationalization, see :
http://www.w3.org/International/questions/qa-i18n.en

To understand how language tags works and tag your translation file properly, see :
http://www.w3.org/International/questions/qa-choosing-language-tags
	
This tool is inspired by GNU gettext :
http://www.gnu.org/savannah-checkouts/gnu/gettext/manual/html_node/Plural-forms.html
	
How to use :
	1. Create a file en.xml (i.e. in assets/lang/en.xml) and add the path as classpath to compiler either 
	by adding "-cp assets/lang" to compiler options or "<classpath name="assets/lang" />" in build.nmml
	
	2. Add entries into your file with this structure :
<?xml version="1.0" encoding="UTF-8"?>
<!-- NO doctype must be declared to allow autcompletion with Translations Proxy. -->
<!-- pluralForm attribute must be a script using "n" as counter to determine pluralForm and returning an Int -->
<translations lang="en" pluralForm="(n!=1)?1:0">
	<t id="test">
		<context>demo word</context>
		<singular>a test</singular>
		<plural>tests</plural>
		<plural form="2">testss</plural><!-- for testing purpose -->
	</t>
	<t id="apple">
		<context>the fruit item</context>
		<singular>an apple</singular>
		<plural>apples</plural>
	</t>
	<t id="thereis">
		<context>demo sentence</context>
		<singular>There is %0.</singular>
		<plural>There are %1 %0.</plural>
	</t>
</translations>

	3. create one file per language you want to support (i.e: de.xml, fr-FR.xml, fr-CA.xml) with the same structure
	but translated content.
	
	4. The following functions are available :
		
		/**
		 * Set the current language file to use.
		 * @param	langFile	path to language file.
		 */
		Localization.set(langFile:String):Void;
		
		/**
		 * Get translation of a text in the current language from a key.
		 * A missing key in a language file will cause the program to fallback on the default language translation.
		 * An innexisting key will cause the program to display the key itself.
		 * @param	key		string id
		 * @param	count	number of elements. Used to know wich singular or plural form has to be choose to translate.
		 * @param	params	parameters to inject into the placeholders of the translated text. Placeholder must be %0, %1, %2, %3, etc.
		 * @return	The translation of a text in the current language from a key.
		 */
		Localization.translate(key:String, count:Int, params:Array<String>):String;
		
		/**
		 * Give acces to available keys id with autocompletion, based on en.xml declarations.
		 */
		Localization.keys:Translations;
		
	Exemple :
		public static var _ = Localization.translate;
		
		public function aFunction(){
			var coinCount:Int = 11;
			Localization.set("lang/en.xml");
			var keys = Localization.keys;
			
			// Play !
			var play:String = _(keys.play);
			// Options
			var options:String = _(keys.options.play);
			// coins
			var coin:String = _(keys.coin, coinCount);
			// There are 10 coins.
			var info:String = _(keys.there_are_X_sthg, coinsCount, [Std.string(coinCount), coin]);
			
			coinCount = coinCount - 10;
			// There is 1 coin.
			var info2:String = _(keys.there_are_X_sthg, coinsCount, [Std.string(coinCount), coin]);
		}
		
	