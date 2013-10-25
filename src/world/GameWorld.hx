package world;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxLayer;
import com.haxepunk.tmx.TmxObject;
import com.haxepunk.tmx.TmxObjectGroup;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import openfl.Assets;
import utopiales2013.Hero;

enum CellType {
	Ground;
	Wall;
}

/**
 * ...
 * @author Samuel Bouchet
 */

class GameWorld extends Scene
{
	public static var instance:Scene ;
	
	private var hero:Hero;

	public function new()
	{
		super();
		
		instance = this;
	}

	override public function update()
	{
		super.update();
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
		
		if (Input.check("up")) {
			hero.move(Direction.Up);
		}
		if (Input.check("down")) {
			hero.move(Direction.Down);
		}
		if (Input.check("left")) {
			hero.move(Direction.Left);
		}
		if (Input.check("right")) {
			hero.move(Direction.Right);
		}

	}
	
	override public function begin()
	{
		// création des objets du niveau
		hero = new Hero();
	/*
		// afficher le niveau (grille)
		var tiles = new TmxEntity( "map/test.tmx" );
		tiles.loadGraphic( "gfx/tileset.png", ["tiles"] ) ;
		var gridWidth = 10;
		var gridHeight = 10;
		
		// collisions de la map
		tiles.loadMask("tiles", "solid", [0]);
		
		// générer la grille depuis le niveau
		var grid:Array<Array<CellType>> = new Array<Array<CellType>>();
		var layer:TmxLayer = tiles.map.getLayer("tiles");
		for (yCell in 0...gridHeight) {
			var row = new Array<CellType>();
			grid.push(row);
			for (xCell in 0...gridWidth) {
				var iTile = layer.tileGIDs[xCell][yCell];
				row.push(
					switch (iTile)
					{
						case 1:
							CellType.Wall;
						default:
							CellType.Ground;
					}
				);
			}
		}
		
		// affiche le personnage à l'endroit prévu
		var tmxObjectGroup:TmxObjectGroup = tiles.map.getObjectGroup("objects");
		for (obj in tmxObjectGroup.objects) {
			if (obj.name == "Start") {
				hero.x = obj.x;
				hero.y = obj.y;
			}
		}
		
		add(tiles);*/
		add(hero);
		
		//hero.layer
		
		super.begin();
	}
	
	override public function end()
	{
		removeAll();
		super.end();
	}
	
}