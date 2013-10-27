package world;
import com.haxepunk.Entity;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.gui.Button;
import com.haxepunk.gui.Control;
import com.haxepunk.gui.FormatAlign;
import com.haxepunk.gui.Label;
import com.haxepunk.Tween;
import com.haxepunk.tweens.misc.MultiVarTween;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.utils.Ease;
import flash.text.TextFormat;
import utopiales2013.Vision;
#if debug
import com.haxepunk.gui.TextInput;
#end
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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import haxe.ds.Option;
import openfl.Assets;
import utopiales2013.Ghost;
import utopiales2013.Hero;
import utopiales2013.Piece;

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
	private static var LAYER_PIECE:Int = 200;
	private static var LAYER_SHADING:Int = 300;
	private static var LAYER_HERO:Int = 800;
	private static var LAYER_GHOST:Int = 900;
	private static var LAYER_VISION:Int = 950;
	private static var LAYER_INTERFACE:Int = 1999;
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
	private var currentMove : Option<{ dir:Direction, to:Point, since:Int }> ;

	private var currentPieces:List<Entity> ;
	
	private var waitForKey:Bool = true;
	private var gameEnd:Bool = false;
	private var updateInit:Bool = false;
	
	private var xmlDebugContent:String;

	private var score:Int ;
	var music:Sfx;

	private static var SHADING_COLOR = 0x7FFF0000 ;
	private var shading:BitmapData ;
	private var halo:BitmapData ;
	var pickUpSfx:Sfx;
	var paradoxSfx:Sfx;

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
			HXP.scene = new WelcomeWorld();
		}
		if (Input.pressed(Key.R)) {
			HXP.scene = new GameWorld(xmlDebugContent);
		}
		
		if (waitForKey && Input.pressed(Key.ANY)) {
			waitForKey = false;
			if (txtWaitForKey.scene != null) {
				this.remove(txtWaitForKey);
			}
		}
		if (gameEnd && Input.pressed(Key.ANY)) {
			var levelName:String = tiles.map.properties.nom;
			HXP.scene = new End(Std.string(score), levelName);
		}
		
		if(!gameEnd && !waitForKey){

			inTime += Std.int( 1000/HXP.frameRate );

			// Detect input
			switch (currentMove) {
				case None :
					if( inTime < (4/5)*TURN_DURATION )
					{
						if (Input.check("up")) {
							var canMove = hero.collide("solid", hero.x, hero.y - moveSpanY) == null ;
							var to = new Point( hero.x, canMove ? hero.y - moveSpanY : hero.y ) ;
							currentMove = Some({dir:Up,to:to,since:inTime}) ;
						} else if (Input.check("down") ) {
							var canMove = hero.collide("solid", hero.x, hero.y + moveSpanY) == null ;
							var to = new Point( hero.x, canMove ? hero.y + moveSpanY : hero.y ) ;
							currentMove = Some({dir:Down,to:to,since:inTime}) ;
						} else if (Input.check("left") ) {
							var canMove = hero.collide("solid", hero.x - moveSpanX, hero.y) == null ;
							var to = new Point( canMove ? hero.x - moveSpanX : hero.x, hero.y ) ;
							currentMove = Some({dir:Left,to:to,since:inTime}) ;
						} else if (Input.check("right") ) {
							var canMove = hero.collide("solid", hero.x + moveSpanX, hero.y ) == null ;
							var to = new Point( canMove ? hero.x + moveSpanX : hero.x, hero.y ) ;
							currentMove = Some({dir:Right,to:to,since:inTime}) ;
						}
					}
				default : // already moving
			}

			// interpolate hero position
			var prevFrame = currentRun.record.get( turn ) ;
			var nextX = prevFrame.x ;
			var nextY = prevFrame.y ;
			var isMoving = true ;
			var currentDir = prevFrame.dir ;
			var moveStartTime = 0 ;
			switch ( currentMove ) {
				case None:
					isMoving = false ;
				case Some( moveInfos ):
					currentDir = moveInfos.dir ;
					nextX = moveInfos.to.x ;
					nextY = moveInfos.to.y ;
			}
			if( moveStartTime > inTime ) moveStartTime = inTime ;
			if( moveStartTime < 0 ) moveStartTime = 0 ;
			hero.x = moveTween( inTime - moveStartTime, TURN_DURATION - moveStartTime, prevFrame.x, nextX ) ;
			hero.y = moveTween( inTime - moveStartTime, TURN_DURATION - moveStartTime, prevFrame.y, nextY ) ;
			hero.play( currentDir, isMoving ) ;

			// move halo
			shading.fillRect( new Rectangle(0,0,shading.width,shading.height), SHADING_COLOR ) ;
			//shading.copyChannel( )

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
				chrono.color = 0x000000;
			} else {
				chrono.color = 0xD20000;
			}
		}
	}

	private function nextTurn()
	{
		// aimante le héro sur la grille
		hero.x = Math.round((hero.x - tiles.x) / 20) * 20 + tiles.x;
		hero.y = Math.round((hero.y - tiles.y) / 20) * 20 + tiles.y;
				
		// condition de fin
		var v:Vision = cast(hero.collide("vision", hero.x, hero.y));
		if (v != null) {
			paradoxSfx.play();
			
			var iSeeYou:Ghost = v.ghost;
			gameEnd = true;
			stopAllAnimations();
			iSeeYou.jump(iSeeYou.direction);
			hero.jump(iSeeYou.backDirection);
			add(gameover);
			
			function shakeFn(e):Void {
				var shake:MultiVarTween = new MultiVarTween(shakeFn, TweenType.OneShot);
				shake.tween(gameover, { x:Math.round(gameover.x + Math.random() * 6 - 3), y:Math.round(gameover.y + Math.random() * 6 - 3) },4,Ease.expoIn );
				addTween(shake, true);
			};
			
			shakeFn(null);
		}
		
		// recuperation bonus
		var retreivedPiece = hero.collide( "piece", hero.x, hero.y ) ;
		if( retreivedPiece != null )
		{
			pickUpSfx.play(0.3);
			remove( retreivedPiece ) ;
			currentPieces.remove( retreivedPiece ) ;
			score += BASE_SCORE ;
			scoreLabel.text = '' + score ;
			scoreLabel.x = 410 - scoreLabel.width;
			spawnPiece() ;
		}

		if(!gameEnd){
			++turn ;
			inTime = inTime % TURN_DURATION ;

			switch( currentMove ) {
				case Some( moveInfos ) :
					hero.x = moveInfos.to.x ;
					hero.y = moveInfos.to.y ;
				case None :
			}
			currentMove = None ;

			record() ;

			if( turn >= TURNS_PER_RUN )
				timeJump() ;
		}

	}
	
	override public function begin()
	{
		// sons
		pickUpSfx = new Sfx("sfx/pickup.wav");
		paradoxSfx = new Sfx("sfx/paradox.wav");
		
		// création des objets du niveau
		hero = new Hero();
		chrono = new Label();
		scoreLabel = new Label("0", 345, -3,0,0);
		gameover = new Label("Paradoxe !");
		gameover.size = 40;
		gameover.color = 0x000000;
		gameover.shadowColor = 0xFFFFFF;
		gameover.shadowBorder = true;
		gameover.x = HXP.screen.width / 2 - gameover.width / 2;
		gameover.y = HXP.screen.height / 2 - gameover.height / 2;
		
		var bg = new Entity() ;
		bg.graphic = new Stamp( Assets.getBitmapData("gfx/interface.png") ) ;
		add(bg) ;
		bg.layer = LAYER_INTERFACE ;
		
		// positionnemetn des élements d'interface
		chrono.x = 233;
		chrono.y = -3;
		chrono.size = 20;
		chrono.shadowColor = 0xFFFFFF;
		chrono.align = FormatAlign.CENTER;
		
		txtWaitForKey = new Label("Commencez a vous deplacer\n   pour entrer en phase");
		txtWaitForKey.size = 20;
		txtWaitForKey.color = 0x000000;
		txtWaitForKey.shadowColor = 0xFFFFFF;
		txtWaitForKey.shadowBorder = true;
		txtWaitForKey.x = Math.round(HXP.screen.width / 2 - gameover.width / 1.5);
		txtWaitForKey.y = Math.round(HXP.screen.height / 2 - gameover.height / 2);
		add(txtWaitForKey);
		scoreLabel.x = 410 - scoreLabel.width;
		scoreLabel.color = 0x000000;
		scoreLabel.shadowColor = 0xFFFFFF;
		scoreLabel.size = 20 ;
		scoreLabel.align = FormatAlign.RIGHT;
		
	
		// afficher le niveau (grille)
		if (xmlDebugContent != null) {
			
			try {
				tiles = new TmxEntity( new TmxMap(xmlDebugContent));
				tiles.loadGraphic( "gfx/tileset.png", ["tiles"] ) ;
			}catch (e:Dynamic) {
				// fall back en cas de pb avec un niveau
				tiles = new TmxEntity( "map/testLD _01.tmx" );
				trace("fail loading level");
			}
		}else {
			tiles = new TmxEntity( "map/test.tmx" );
		}

		moveSpanX = tiles.map.tileHeight ;
		moveSpanY = tiles.map.tileWidth ;
		gridWidth = tiles.map.width ;
		gridHeight = tiles.map.height ;
		tiles.y = HXP.screen.height - tiles.map.fullHeight;
		tiles.x = HXP.screen.width- tiles.map.fullWidth;
		
		var shadingEntity = new Entity() ;
		shading = new BitmapData( tiles.map.fullWidth, tiles.map.fullHeight, true, SHADING_COLOR ) ;
		shadingEntity.graphic = new Stamp(shading) ;
		halo = Assets.getBitmapData("gfx/halo.png") ;

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
		add(shadingEntity) ;
		shadingEntity.layer = LAYER_SHADING ;
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
		music.loop(0.95);
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

		var piece = new Piece() ;
		piece.layer = LAYER_PIECE;
		add(piece) ;
		piece.x = spawnX ;
		piece.y = spawnY ;

	}
	
	override public function end()
	{
		music.stop();
		removeAll();
		super.end();
	}

	private static function moveTween( inTime:Float, totalTime:Float, tweenStart:Float, tweenEnd:Float ):Float
	{
		var t = inTime ;
		var b = tweenStart ;
		var c = tweenEnd - tweenStart ;
		var d = totalTime ;
		return (t/d * c) + b ;
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
