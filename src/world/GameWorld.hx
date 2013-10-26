package world;
import com.haxepunk.Entity;
import com.haxepunk.gui.Label;
import com.haxepunk.HXP;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.Scene;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxLayer;
import com.haxepunk.tmx.TmxObject;
import com.haxepunk.tmx.TmxObjectGroup;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.geom.Point;
import haxe.ds.Option;
import openfl.Assets;
import utopiales2013.Ghost;
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
	ghost:Ghost
}

class GameWorld extends Scene
{
	public static var instance:Scene ;

	private static var TURNS_PER_RUN:Int = 20 ;
	private static var TURN_DURATION:Int = 250 ; // duration of a turn in ms
	private static var DETECTION_DISTANCE:Int = 4 ; // vision en cases des ghosts (inclus la case du ghost lui même)
	
	private static var LAYER_GUI:Int = 100;
	private static var LAYER_HERO:Int = 800;
	private static var LAYER_GHOST:Int = 900;
	private static var LAYER_VISION:Int = 950;
	private static var LAYER_MAP:Int = 2000;
	
	private var moveSpanX:Float ;
	private var moveSpanY:Float ;

	private var hero : Hero ;
	private var chrono:Label;
	
	private var runs : List<Run> ;
	private var currentRun : Run ;

	private var turn : Int ; // turn in the current run
	private var inTime : Int ; // ms since turn start
	private var currentMove : Option<Direction> ;
	

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

		// interpolate hero position
		var prevFrame = currentRun.record.get(turn) ;
		var nextX = prevFrame.x ;
		var nextY = prevFrame.y ;
		var currentDir = Up ;
		var isMoving = true ;
		switch ( currentMove ) {
			case None:
				currentDir = prevFrame.dir ;
				isMoving = false ;
			case Some( Up )		:
				nextY -= moveSpanY ;
				currentDir = Up ;
			case Some( Down )	:
				nextY += moveSpanY ;
				currentDir = Down ;
			case Some( Left )	:
				nextX -= moveSpanX ;
				currentDir = Left ;
			case Some( Right )	:
				nextX += moveSpanX ;
				currentDir = Right ;
		}
		hero.x = moveTween( inTime, TURN_DURATION, prevFrame.x, nextX ) ;
		hero.y = moveTween( inTime, TURN_DURATION, prevFrame.y, nextY ) ;
		hero.play( currentDir, isMoving ) ;

		// pilot ghosts
		for( r in runs )
		{
			prevFrame = r.record.get( turn ) ;
			var nextFrame = r.record.get( turn + 1 ) ;
			r.ghost.x = moveTween( inTime, TURN_DURATION, prevFrame.x, nextFrame.x ) ;
			r.ghost.y = moveTween( inTime, TURN_DURATION, prevFrame.y, nextFrame.y ) ;
			r.ghost.play( nextFrame.dir, prevFrame.x != nextFrame.x || prevFrame.y != nextFrame.y ) ;
		}
		// turn advancement
		if( inTime > TURN_DURATION )
		{
			
			nextTurn() ;
		}		var runDuration = (TURNS_PER_RUN * TURN_DURATION);
		var remainingTime:Float = Math.ceil((runDuration - turn * TURN_DURATION) / 1000);
		var remainingTimeStr:String = Std.string(remainingTime);
		if (remainingTimeStr.indexOf(".") < 0) {
			remainingTimeStr = remainingTimeStr + ".0";
		}
		trace(remainingTimeStr);
		chrono.text = Std.string(remainingTime);
		if (remainingTime > 3) {
			chrono.color = 0xFFFFFF;
		} else {
			chrono.color = 0xFF3E3E;
		}
	}

	private function nextTurn()
	{

		++turn ;
		inTime = inTime % TURN_DURATION ;

		record() ;

		currentMove = None ;
		if (Input.check("up"))
			currentMove = Some(Up) ;
		else if (Input.check("down"))
			currentMove = Some(Down) ;
		else if (Input.check("left"))
			currentMove = Some(Left) ;
		else if (Input.check("right"))
			currentMove = Some(Right) ;

		if( turn >= TURNS_PER_RUN )
			timeJump() ;

	}
	
	override public function begin()
	{
		// création des objets du niveau
		hero = new Hero();
		chrono = new Label();
		
		// positionnemetn des élements d'interface
		chrono.x = Math.round(HXP.screen.width/2 - 20);
		chrono.y = 5;
		chrono.size = 48;
	
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
		tiles.layer = LAYER_MAP;
		add(hero);
		hero.layer = LAYER_HERO;
		add(chrono);
		chrono.layer = LAYER_GUI;

		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ],
			ghost : null
		} ;
		currentMove = None ;
		
		super.begin();
	}

	private function timeJump()
	{
		currentRun.ghost = new Ghost(DETECTION_DISTANCE, moveSpanX, moveSpanY) ;
		add(currentRun.ghost) ;
		currentRun.ghost.layer = LAYER_GHOST;
		
		add(currentRun.ghost.vision) ;
		currentRun.ghost.vision.layer = LAYER_VISION;
		
		runs.add( currentRun ) ;
		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ],
			ghost : null
		}
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

	private static function moveTween( inTime:Float, totalTime:Float, tweenStart:Float, tweenEnd:Float ):Float
	{
		var t = inTime ;
		var b = tweenStart ;
		var c = tweenEnd - tweenStart ;
		var d = totalTime ;

		t /= d/2;
		if (t < 1) return c/2*t*t + b;
		t--;
		return -c/2 * (t*(t-2) - 1) + b;
	}
	
}
