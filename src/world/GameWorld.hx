package world;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.gui.Button;
import com.haxepunk.gui.Control;
import com.haxepunk.gui.Label;
import com.haxepunk.gui.TextInput;
import com.haxepunk.HXP;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.Scene;
import com.haxepunk.Sfx;
import com.haxepunk.tmx.TmxEntity;
import com.haxepunk.tmx.TmxLayer;
import com.haxepunk.tmx.TmxMap;
import com.haxepunk.tmx.TmxObject;
import com.haxepunk.tmx.TmxObjectGroup;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.display.Loader;
import flash.events.Event;
import flash.geom.Point;
import flash.net.URLLoader;
import flash.net.URLRequest;
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
	
	private static var BASE_SCORE = 10 ;

	private static var LAYER_GUI:Int = 100;
	private static var LAYER_PIECE:Int = 805;
	private static var LAYER_HERO:Int = 800;
	private static var LAYER_GHOST:Int = 900;
	private static var LAYER_VISION:Int = 950;
	private static var LAYER_MAP:Int = 2000;
	
	private var tiles:TmxEntity ;
	private var gridWidth:Int ;// in tiles
	private var gridHeight:Int ;
	private var moveSpanX:Float ;
	private var moveSpanY:Float ;

	private var hero : Hero ;
	private var chrono:Label;
	private var scoreLabel:Label;
	private var gameover:Label;
	private var txtWaitForKey:Label;
	
	private var runs : List<Run> ;
	private var currentRun : Run ;

	private var turn : Int ; // turn in the current run
	private var inTime : Int ; // ms since turn start
	private var currentMove : Option<Direction> ;

	private var currentPieces:List<Entity> ;
	
	private var waitForKey:Bool = true;
	private var gameEnd:Bool = false;
	private var updateInit:Bool = false;
	
	private var xmlDebugContent:String;
	
	

	private var score:Int ;
	var music:Sfx;

	public function new(xmlContent:String = null )
	{
		xmlDebugContent = xmlContent;
		
		super();
		
		instance = this;

		runs = new List() ;
	}

	override public function update()
	{
		super.update();
		
		if (!updateInit) {
			updateInit = true;
			spawnPiece() ;
			spawnPiece() ;
		}
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = new GameWorld(xmlDebugContent);
		}
		
		if (waitForKey && Input.pressed(Key.ANY)) {
			waitForKey = false;
			if (txtWaitForKey.scene != null) {
				this.remove(txtWaitForKey);
			}
		}
		if (gameEnd && Input.pressed(Key.ANY)) {
			HXP.scene = new WelcomeWorld();
		}
		
		if(!gameEnd && !waitForKey){

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
				r.ghost.x = ghostTween( inTime, TURN_DURATION, prevFrame.x, nextFrame.x ) ;
				r.ghost.y = ghostTween( inTime, TURN_DURATION, prevFrame.y, nextFrame.y ) ;
				r.ghost.play( nextFrame.dir, prevFrame.x != nextFrame.x || prevFrame.y != nextFrame.y ) ;
			}
			// turn advancement
			if( inTime > TURN_DURATION )
			{
				
				nextTurn() ;
			}		var runDuration = (TURNS_PER_RUN * TURN_DURATION);
			var remainingTime:Float = Math.ceil((runDuration - turn * TURN_DURATION) / 1000);
			var remainingTimeStr:String = Std.string(remainingTime);
			chrono.text = Std.string(remainingTime);
			if (remainingTime > 3) {
				chrono.color = 0xFFFFFF;
			} else {
				chrono.color = 0xFF3E3E;
			}
		}
	}

	private function nextTurn()
	{
		// aimante le héro sur la grille
		hero.x = Math.round((hero.x - tiles.x) / 20) * 20 + tiles.x;
		hero.y = Math.round((hero.y - tiles.y) / 20) * 20 + tiles.y;
				
		// condition de fin
		if (hero.collide("vision", hero.x, hero.y) != null) {
			gameEnd = true;
			stopAllAnimations();
			add(gameover);
		}
		
		// recuperation bonus
		var retreivedPiece = hero.collide( "piece", hero.x, hero.y ) ;
		if( retreivedPiece != null )
		{
			remove( retreivedPiece ) ;
			currentPieces.remove( retreivedPiece ) ;
			score += BASE_SCORE ;
			scoreLabel.text = '' + score ;
			scoreLabel.x = HXP.screen.width - (scoreLabel.width + 4) ;
			spawnPiece() ;
		}

		if(!gameEnd){
			++turn ;
			inTime = inTime % TURN_DURATION ;

			record() ;

			currentMove = None ;
			if (Input.check("up"))
				if( hero.collide("solid", hero.x, hero.y - moveSpanY) == null )
					currentMove = Some(Up) ;
				else
					hero.play( Up, false ) ;
			else if (Input.check("down") )
				if( hero.collide("solid", hero.x, hero.y + moveSpanY) == null )
					currentMove = Some(Down) ;
				else
					hero.play( Down, false ) ;
			else if (Input.check("left") )
				if( hero.collide("solid", hero.x - moveSpanX, hero.y) == null )
					currentMove = Some(Left) ;
				else
					hero.play( Left, false ) ;
			else if (Input.check("right") )
				if( hero.collide("solid", hero.x + moveSpanX, hero.y ) == null )
					currentMove = Some(Right) ;
				else
					hero.play( Right, false ) ;

			record() ;

			if( turn >= TURNS_PER_RUN )
				timeJump() ;
		}

	}
	
	override public function begin()
	{
		// création des objets du niveau
		hero = new Hero();
		chrono = new Label();
		scoreLabel = new Label();
		gameover = new Label("Paradoxe !");
		gameover.size = 40;
		gameover.color = 0x000000;
		gameover.x = HXP.screen.width / 2 - gameover.width / 2;
		gameover.y = HXP.screen.height / 2 - gameover.height / 2;
		
		// positionnemetn des élements d'interface
		chrono.x = Math.round(HXP.screen.width/2 - 20);
		chrono.y = 0;
		chrono.size = 20;
		
		txtWaitForKey = new Label(" Appuyez sur une touche\npour entrer dans la phase");
		txtWaitForKey.size = 20;
		txtWaitForKey.color = 0x000000;
		txtWaitForKey.x = Math.round(HXP.screen.width / 2 - gameover.width / 1.5);
		txtWaitForKey.y = Math.round(HXP.screen.height / 2 - gameover.height / 2);
		add(txtWaitForKey);
		scoreLabel.text = '0' ;
		scoreLabel.color = 0xFFFFFF ;
		scoreLabel.x = Math.round(HXP.screen.width - (scoreLabel.width + 15)) ;
		scoreLabel.y = 5 ;
		scoreLabel.size = 20 ;
	
		// afficher le niveau (grille)
		if (xmlDebugContent != null) {
			tiles = new TmxEntity( new TmxMap(xmlDebugContent));
		}else {
			tiles = new TmxEntity( "map/test.tmx" );
		}
		
		tiles.loadGraphic( "gfx/tileset.png", ["tiles"] ) ;
		moveSpanX = tiles.map.tileHeight ;
		moveSpanY = tiles.map.tileWidth ;
		gridWidth = tiles.map.width ;
		gridHeight = tiles.map.height ;
		tiles.y = HXP.screen.height - tiles.map.fullHeight;
		tiles.x = HXP.screen.width / 2 - tiles.map.fullWidth / 2;
		
		// collisions de la map
		tiles.loadMask("tiles", "solid", [25]);
		
		// générer la grille depuis le niveau
		var gridWidth = tiles.map.width;
		var gridHeight = tiles.map.height;
		
		// affiche le personnage à l'endroit prévu
		var tmxObjectGroup:TmxObjectGroup = tiles.map.getObjectGroup("objects");
		for (obj in tmxObjectGroup.objects) {
			if (obj.name == "start") {
				hero.x = Math.round(obj.x/20)*20+tiles.x;
				hero.y = Math.round(obj.y/20)*20+tiles.y;
			}
		}
		
		add(tiles);
		tiles.layer = LAYER_MAP;
		add(hero);
		hero.layer = LAYER_HERO;
		add(chrono);
		chrono.layer = LAYER_GUI;
		add(scoreLabel);
		scoreLabel.layer = LAYER_GUI;

		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ],
			ghost : null
		} ;
		currentMove = None ;
		
		currentPieces = new List() ;

		score = 0 ;

		#if debug
			// test dynamic de niveaux
			var inputText:TextInput = new TextInput("testLD _", 250, 0, 150, 20);
			inputText.size = 10;
			var bLoad:Button = new Button("Charger", 400, 0, 50, 20);
			bLoad.size = 10;
			add(inputText);
			add(bLoad);
			bLoad.addEventListener(Button.CLICKED, function(e) {
				var myLoader:URLLoader = new URLLoader();
				var request:URLRequest = new URLRequest(inputText.text);
				myLoader.addEventListener(Event.COMPLETE, function(e) {
					HXP.scene = new GameWorld(cast(myLoader.data));
				});
				myLoader.load(request);
			});
		#end
		
		super.begin();
		
		music = new Sfx("music/mainLoop.mp3");
		music.loop(0.4);
	}

	private function timeJump()
	{
		// reset positions and pause the game
		currentRun.ghost = new Ghost(DETECTION_DISTANCE, moveSpanX, moveSpanY) ;
		add(currentRun.ghost) ;
		currentRun.ghost.layer = LAYER_GHOST;
		
		add(currentRun.ghost.vision) ;
		currentRun.ghost.vision.layer = LAYER_VISION;
		
		// remember run
		runs.add(currentRun) ;
		
		// init ghost position before pausing
		var firstRun:Run = runs.first();
		currentRun.ghost.x = firstRun.record.get(0).x;
		currentRun.ghost.y = firstRun.record.get(0).y;
		currentRun.ghost.play(firstRun.record.get(0).dir, false);
		
		// init new run
		currentRun = {
			record : [ 0 => { x:hero.x, y:hero.y, dir:hero.direction } ],
			ghost : null
		}

		turn = 0 ;
		inTime = 0 ;
		
		// stop all animations
		stopAllAnimations();
		
		
		waitForKey = true;
		if (txtWaitForKey.scene == null) {
			add(txtWaitForKey);
		}
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

	private function spawnPiece(){

		var excluders : Array<Entity> = Lambda.array( currentPieces ) ;
		excluders.push( hero ) ;

		var spawnX, spawnY ;
		var isValidPosition = true;
		var tries = 0;
		do{

			spawnX = tiles.x + Std.int( Math.random() * gridWidth )*moveSpanX ;
			spawnY = tiles.y + Std.int( Math.random() * gridHeight )*moveSpanY ;

			isValidPosition = (this.collidePoint( "solid", spawnX + moveSpanX / 2, spawnY + moveSpanY / 2 ) == null);
			if(isValidPosition){
				for( ex in excluders )
				{
					if (HXP.distance(ex.x, ex.y, spawnX,  spawnY) < 4.5 * (moveSpanX + moveSpanY) / 2) {
						isValidPosition = false;
						break;
					}
				}
			}
			tries++;
		} while ( !isValidPosition && tries < 1000);

		var piece = new Entity() ;
		var spritemap = new Spritemap("gfx/SOLS.png", 20, 20) ;
		spritemap.add( "std", [3], 1 ) ;
		spritemap.play("std") ;
		piece.graphic = spritemap ;
		piece.layer = LAYER_PIECE;
		add(piece) ;

		piece.x = spawnX ;
		piece.y = spawnY ;
		piece.type = "piece" ;
		piece.setHitbox(19, 19, -2, -2);

	}
	
	override public function end()
	{
		music.stop();
		removeAll();
		super.end();
	}

	private static function moveTween( inTime:Float, totalTime:Float, tweenStart:Float, tweenEnd:Float ):Float
	{
		/*var t = inTime ;
		var b = tweenStart ;
		var c = tweenEnd - tweenStart ;
		var d = totalTime ;
		return (t/d * c) + b ;
		*/
		return ghostTween(inTime, totalTime, tweenStart, tweenEnd) ;
	}

	private static function ghostTween( inTime:Float, totalTime:Float, tweenStart:Float, tweenEnd:Float ):Float
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
	
	function stopAllAnimations():Void
	{
		for (r in runs) {
			r.ghost.play(r.ghost.direction,false);
		}
		hero.play(hero.direction, false);
	}
	
}
