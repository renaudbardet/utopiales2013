package com.matttuttle.localization;

import haxe.xml.Fast;

/**
 * The singular and plurals translations for one key.
 * @author Samuel Bouchet
 */
class Translation
{

	/**
	 *
	 * @param	singular	singular translation
	 * @param	plurals		plural translations
	 */
	public function new(xml:Fast)
	{
		// list plurals
		plurals = new IntMap<String,String>();
		for (p in xml.nodes.plural)
		{
			plurals.set((p.has.form ? Std.parseInt(p.att.form) : 2), p.innerData);
		}
		if (xml.hasNode.singular)
		{
			singular = xml.node.singular.innerData;
		}
		else
		{
			singular = xml.innerData;
		}
	}

	public function getString(pluralForm:Int)
	{
		if (plurals.exists(pluralForm))
		{
			return plurals.get(pluralForm);
		}
		else
		{
			return singular;
		}
	}

	private var singular:String;
	private var plurals:IntMap<String,String>;

}