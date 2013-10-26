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
import utopiales2013.Chrono;
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
	record : Map<Int,RecordFrame>,
	ghost:Hero
}

class GameWorld extends Scene
{
	public static var instance:Scene ;

	private static var TURNS_PER_RUN:Int = 20 ;
	private static var TURN_DURATION:Int = 250 ; // duration of a turn
	
	private var moveSpanX:Float ;
	private var moveSpanY:Float ;

	private var hero : Hero ;
	private var chrono:Chrono;
	
	private var runs : List<Run> ;
	private var currentRun : Run ;

	private var turn : Int ; // turn in the current run
	private var inTime : Int ; // ms since turn start
	

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

		inTime += Std.int( 1000/HXP.frameRate );

		// pilot ghosts
		for( r in runs )
		{
			var prevFrame = r.record.get( turn ) ;
			var nextFrame = r.record.get( turn + 1 ) ;
			var interX = prevFrame.x + ( nextFrame.x - prevFrame.x ) * ( inTime / TURN_DURATION ) ;
			var interY = prevFrame.y + ( nextFrame.y - prevFrame.y ) * ( inTime / TURN_DURATION ) ;
			//r.ghost.x = interX ;
			//r.ghost.y = interY ;
			r.ghost.x = prevFrame.x ;
			r.ghost.y = prevFrame.y ;
		}
		
		// turn advancement
		if( inTime > TURN_DURATION )
			nextTurn() ;

		var remainingTime = Std.string(Math.round(inTime * 100) / 100);
		chrono.text = 'Time : $remainingTime' ;
		
	}

	private function nextTurn()
	{

		++turn ;
		inTime = inTime % TURN_DURATION ;

		record() ;

		var move = false;
		if (Input.check("up")) {
			hero.move(Direction.Up, moveSpanY);
			move = true;
		}
		else if (Input.check("down")) {
			hero.move(Direction.Down, moveSpanY);
			move = true;
		}
		else if (Input.check("left")) {
			hero.move(Direction.Left, moveSpanX);
			move = true;
		}
		else if (Input.check("right")) {
			hero.move(Direction.Right, moveSpanX);
			move = true;
		}
		if (!move) {
			hero.stop();
		}

		if( turn >= TURNS_PER_RUN )
			timeJump() ;

	}
	
	override public function begin()
	{
		// création des objets du niveau
		hero = new Hero();
		chrono = new Chrono();
		
		// positionnemetn des élements d'interface
		chrono.x = Math.round(HXP.screen.width/2 - 20);
		chrono.y = 5;
	
		// afficher le niveau (grille)
		var tiles = new TmxEntity( "map/test.tmx" );
		tiles.loadGraphic( "gfx/tileset.png", ["tiles"] ) ;
		moveSpanX = tiles.map.tileHeight ;
		moveSpanY = tiles.map.tileWidth ;
		var gridWidth = 10;
		var gridHeight = 10;
		tiles.y = HXP.screen.height / 2 - tiles.map.fullHeight / 2;
		tiles.x = HXP.screen.width / 2 - tiles.map.fullWidth / 2;
		
		// collisions de la map
		tiles.loadMask("tiles", "solid", [0]);
		
		// générer la grille depuis le niveau
		var gridWidth = tiles.map.width;
		var gridHeight = tiles.map.height;
		var grid:Array<Array<CellType>> = new Array<Array<CellType>>();
		var layer:TmxLayer = tiles.map.getLayer("tiles");
		for (yCell in 0...gridHeight) {
			var row = new Array<CellType>();
			grid.push(row);
			for (xCell in 0...gridWidth) {
				var iTile = layer.tileGIDs[yCell][xCell];
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
		add(chrono);

		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ],
			ghost : null
		} ;
		
		super.begin();
	}

	private function timeJump()
	{
		trace("time jump") ;
		currentRun.ghost = new Hero() ;
		add(currentRun.ghost) ;
		runs.add( currentRun ) ;
		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ],
			ghost : null
		} ;
		turn = 0 ;
		inTime = 0 ;
	}

	// called every .25s or so to record the current pos of the hero in the current run
	private function record()
	{
		currentRun.record.set(
			turn,
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
