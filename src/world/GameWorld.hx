package world;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxLayer;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;

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

	}
	
	override public function begin()
	{
	
		// afficher le niveau (grille)
		var tmxEntity:TmxEntity = new TmxEntity(null); // TODO : récupérer le TMXEntity
		var gridWidth = 10;
		var gridHeight = 10;
		
		
		// générer la grille depuis le niveau
		var grid:Array<Array<CellType>> = new Array<Array<CellType>>();
		var layer:TmxLayer = tmxEntity.map.getLayer("tiles");
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
		
		//
		
		
		super.begin();
	}
	
	override public function end()
	{
		removeAll();
		super.end();
	}
	
}