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

/**
 * ...
 * @author Samuel Bouchet
 */

enum CellType {
	Ground;
	Wall;
}

typedef RecordFrame = {
	x : Float,
	y : Float,
	dir : Direction
}

typedef Run =  {
	record : Map<Int,RecordFrame>
}

class GameWorld extends Scene
{
	public static var instance:Scene ;

	private static var TIME_TO_RESET:Int = 10000 ; // time before the jump, in ms
	private static var RECORD_FRAME_RATE = 250 ; // ms between two snapshots
	
	private var hero:Hero;
	private var runs : List<Run> ;
	private var currentRun : Run ;

	private var time : Int ; // the ingame time in ms, gets reseted every xx seconds

	public function new()
	{
		super();
		
		instance = this;

		runs = new List() ;
	}

	override public function update()
	{
		super.update();
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
		
		var move = false;
		if (Input.check("up")) {
			hero.move(Direction.Up);
			move = true;
		}
		if (Input.check("down")) {
			hero.move(Direction.Down);
			move = true;
		}
		if (Input.check("left")) {
			hero.move(Direction.Left);
			move = true;
		}
		if (Input.check("right")) {
			hero.move(Direction.Right);
			move = true;
		}
		if (!move) {
			hero.stop();
		}

		var elapsed = Std.int( 1000/HXP.frameRate );

		// if we have reach a new recordFrame, record
		if( Math.floor(time / 250) < Math.floor(time + elapsed / 250) )
			record() ;

		time += elapsed ;

		if( time >= TIME_TO_RESET )
			timeJump() ;

		// dump records
		for( r in runs )
		{
			var prevRecTime :Int = 0 ;
			var nextRecTime :Int = 0 ;
			for( ts in r.record.keys() )
			{
				if( ts < time )
					prevRecTime = ts ;
				else{
					nextRecTime = ts ;
					break ;
				}
			}
			var interval = nextRecTime - prevRecTime ;
			var timeIn = time - prevRecTime ;
			var prevFrame = r.record.get( prevRecTime ) ;
			var nextFrame = r.record.get( nextRecTime ) ;
			var interX = prevFrame.x + ( nextFrame.x - prevFrame.x ) * ( timeIn / interval ) ;
			var interY = prevFrame.y + ( nextFrame.y - prevFrame.y ) * ( timeIn / interval ) ;
			trace( '{ x : $interX, y :  $interY }' ) ;
		}

	}
	
	override public function begin()
	{
		// création des objets du niveau
		hero = new Hero();
	
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
			if (obj.name == "start") {
				hero.x = obj.x;
				hero.y = obj.y;
			}
		}
		
		add(tiles);
		add(hero);
		
		//hero.layer

		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ]
		} ;
		
		super.begin();
	}

	private function timeJump()
	{
		trace("time jump") ;
		runs.add( currentRun ) ;
		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ]
		} ;
		// remove ghosts and create new ones
		time = 0 ;
	}

	// called every .25s or so to record the current pos of the hero in the current run
	private function record()
	{
		currentRun.record.set(
			time,
			{
				x : hero.x,
				y : hero.y,
				dir : hero.direction
			}
		) ;
	}
	
	override public function end()
	{
		removeAll();
		super.end();
	}
	
}
