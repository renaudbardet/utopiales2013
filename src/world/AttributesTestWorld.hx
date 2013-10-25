package world;
import com.haxepunk.gui.Label;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.Scene;
import flash.events.Event;
import flash.Lib;
import tools.attributes.AttributeSet;
import tools.attributes.Bonus;
import tools.attributes.Effect;
import tools.attributes.Item;

/**
 * ...
 * @author Samuel Bouchet
 */

class AttributesTestWorld extends Scene
{
	private var label:Label;
	public static var instance:Scene ;

	public function new()
	{
		super();
		
		var str:String = "";
		
		var hero:AttributeSet = new AttributeSet();
		hero.get("str").baseValue = 10;
		hero.get("mpMax").baseValue = 275;
		hero.get("AP").baseValue = 20;
		
		var archange:Item = new Item("Archangel staff");
		archange.addAdditionBonus("mpMax", 1000, 0, "Add 1000 mana");
		archange.add(new Bonus("AP", function(attributes:AttributeSet, bonus:Bonus):Float {
			return attributes.get("mpMax").value * 0.03;
		}, 1, "Convert 3% of mana max to AP"));
		
		var rabadon:Item = new Item("Rabadon's hat");
		rabadon.addAdditionBonus("AP", 100, 0);
		rabadon.addMultiplicationBonus("AP", 0.25, 2, "Increase AP by 25%");
		rabadon.addEffect(new Effect(function(c:Dynamic, t:Dynamic):Bool { str += "attaque !\n"; return true; }, 0, "Attaque spéciale rab"));

		// a shield that gives +5 def and +20 maxHp
		var shield:Item = new Item("Basic Shield");
		shield.addAdditionBonus("def", 5);
		shield.addAdditionBonus("hpMax", 20);
		
		// another way to create Bonus on a shield
		var betterShield:Item = new Item("Better Shield");
		betterShield.addAdditionBonus("def", 10);
		betterShield.addAdditionBonus("hpMax", 30);
		
		var defGemForShield:Item = new Item("Def gem");
		defGemForShield.addMultiplicationBonus("def", 1, 0, "double def bonus");
		
		var defGemMod:Item = new Item("Mod");
		defGemMod.addMultiplicationBonus("def", 0.2, 1, "add 20% efficiency to a gem");
		defGemMod.addAdditionBonus("def", 1, 0, "add +1 def to a gem");
	
		var lifeGemForShield:Item = new Item("Life gem");
		lifeGemForShield.addMultiplicationBonus("hpMax", 1,0,"double hpMax bonus");
		
		// a sword that gives +5 str
		var sword:Item = new Item("Basic Sword");
		sword.addAdditionBonus("str", 5);
		
		// 3 Bonuss for this special sword
		var specialSword:Item = new Item("Special Sword");
		// a normal Bonus
		specialSword.addAdditionBonus("str", 5);
		// a Bonus based on str total value of the hero with special description.
		specialSword.addMultiplicationBonus("str", 0.5, 1, "+25% of total str");
		specialSword.addMultiplicationBonus("str", 0.5, 2, "+50% of total str + including others bonus from this Item");
		// special Bonus based on str total but requiering another Item to be equiped
		var specialDefBonus = function(attributes:AttributeSet, bonus:Bonus):Float{
			if (attributes.hasItem(betterShield.name)) {
				bonus.label = "[with Better Shied] +50% of total str";
				return attributes.get("str").value * 0.5;
			} else {
				bonus.label = "[Better Shied required] +50% of total str";
				return 0;
			}
		}
		specialSword.add(new Bonus("def", specialDefBonus, 3));
		
		
		//RENDU
		var ligne:String = "-";
		for (i in 0...40) {
			ligne += ".-";
		}
		
		rabadon.simulateOn(hero);
		str += rabadon.toString() + "\n";
		str += ligne+ "\n";
		
		str += hero.toString() + "\n";
		str += ligne+ "\n";
		
		hero.equip(archange);
		hero.equip(rabadon);
		rabadon.use(null, null);
		
		str += hero.toString()+ "\n";
		str += ligne+ "\n";
		
		//hero.unequip(archange);
		//hero.unequip(rabadon);
		
		hero.equip(sword);
		hero.equip(shield);
		shield.equip(defGemForShield);
		defGemForShield.equip(defGemMod);
		
		str += hero.toString()+ "\n";
		str += ligne+ "\n";
		
		shield.unequip(defGemForShield);
		shield.equip(lifeGemForShield);
		hero.unequip(sword);
		hero.equip(specialSword);
		
		str += hero.toString()+ "\n";
		str += ligne+ "\n";
		
		hero.unequip(shield);
		hero.equip(betterShield);
		specialSword.equip(defGemForShield);
		
		str += hero.toString()+ "\n";
		str += ligne + "\n";
		
		add(label = new Label(str, 5, 10));
		label.color = 0xFFFFFF;
		label.size = 8;
		
		instance = this;
	}
	override public function update()
	{
		super.update();
		
		var h = HXP.screen.height / HXP.screen.scale;
		if (label.height > h) {
			label.y = 30 + (- mouseY * (label.height - h + 60) / h);
		}
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
	}
	
	override public function begin()
	{
		super.begin();
	}
	
	override public function end()
	{
		super.end();
	}
	
}