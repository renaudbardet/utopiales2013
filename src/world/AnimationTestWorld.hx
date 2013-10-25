package world;
import com.haxepunk.animation.AnimatedSprite;
import com.haxepunk.animation.Sequence;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import flash.display.MovieClip;
import flash.system.ApplicationDomain;
import openfl.Assets;
import flash.display.Loader;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;

/**
 * ...
 * @author Samuel Bouchet
 */

class AnimationTestWorld extends Scene
{
	private var shape:AnimatedSprite;
	private var as:AnimatedSprite;
	private var as2:AnimatedSprite;
	private var swfLoader:Loader;
	private var swfLoader2:Loader;
	
	public static var instance:Scene ;

	public function new()
	{
		super();
		
		var swfBA:ByteArray = Assets.getBytes("gfx/anim/grow.swf");
		
		swfLoader = new Loader();
		swfLoader.contentLoaderInfo.addEventListener(Event.INIT, swfLoaded);
		swfLoader.loadBytes(swfBA);
		
		var swfBA2:ByteArray = Assets.getBytes("gfx/anim/PastWatch.swf");
		
		swfLoader = new Loader();
		swfLoader.contentLoaderInfo.addEventListener(Event.INIT, swfLoaded2);
		var ctx = new flash.system.LoaderContext(false, Lib.current.stage.loaderInfo.applicationDomain);
		swfLoader.loadBytes(swfBA2, ctx);

		/*
		as2 = new AnimatedSprite();
		var s = new Sequence("test", 24, true);
		var mv = swf2;
		s.buildFromMovieClip(mv);
		as2.add(s);
		as2.play("test");
		
		addGraphic(as2);
		as2.x = 300;
		as2.y = 150;
		
		swfLoader = new Loader();
		swfLoader.contentLoaderInfo.addEventListener(Event.INIT, swfLoaded);
		swfLoader.loadBytes(swfBA);
		
		instance = this;
		
		return;
		
		var t:Float = Lib.getTimer();
		
		var swf:MovieClip = Assets.getMovieClip("gfx/anim/PastWatch.swf");
		var fx = swf.symbols.get("Main_FX");
		
		var t2:Float = Lib.getTimer();
		//trace(t2 - t + " ms to load a swf of " + Math.round(swfBA1.length / 1024) + " Ko.");
		
		
		swfLoader2 = new flash.display.Loader();
		swfLoader2.contentLoaderInfo.addEventListener(Event.INIT, swfLoaded2);
		var ctx = new flash.system.LoaderContext();
		ctx.applicationDomain = flash.system.ApplicationDomain.currentDomain;
		swfLoader2.loadBytes(swfBA1, ctx);

		as = new AnimatedSprite();
		var s:Sequence = new Sequence("left", 12, true);
		var mv = swf.createMovieClip("Main_FX");
		mv.scaleX = 0.6;
		mv.scaleY = 0.6;
		s.buildFromMovieClip(mv, 2);
		
		var s2:Sequence = new Sequence("up", 12, true);
		mv.rotation = Math.PI/2;
		s2.buildFromMovieClip(mv, 2);
		
		var s3:Sequence = new Sequence("right", 12, true);
		mv.rotation = Math.PI;
		s3.buildFromMovieClip(mv, 2);
		
		var s4:Sequence = new Sequence("down", 12, true);
		mv.rotation = -Math.PI/3;
		s4.buildFromMovieClip(mv, 2);
		
		t2 = Lib.getTimer();
		trace(t2 - t + " ms for " + s.frames.length + " frames.");
		
		as.add(s);
		as.add(s2);
		as.add(s3);
		as.add(s4);
		addGraphic(as);
		as.x = 303;
		as.y = 100;
		as.play("left");
		
		*/
	}
	
	private function swfLoaded(e:Event):Void
	{
		var content:Dynamic = swfLoader.content;
		
		var as3 = new AnimatedSprite();
		var s = new Sequence("test", 24, true);
		s.buildFromMovieClip(cast(content));
		as3.add(s);
		as3.play("test");
		
		as3.x = 150;
		as3.y = 150;
		addGraphic(as3);
	}
	
	private function swfLoaded2(e:Event):Void
	{

		as = new AnimatedSprite();
		var s:Sequence = new Sequence("left", 12, true);
		var mv = Type.createInstance(Type.resolveClass("Main_FX"),[]);
		mv.scaleX = 0.6;
		mv.scaleY = 0.6;
		s.buildFromMovieClip(mv, 2);
		
		var s2:Sequence = new Sequence("up", 12, true);
		mv.rotation = Math.PI/2;
		s2.buildFromMovieClip(mv, 2);
		
		var s3:Sequence = new Sequence("right", 12, true);
		mv.rotation = Math.PI;
		s3.buildFromMovieClip(mv, 2);
		
		var s4:Sequence = new Sequence("down", 12, true);
		mv.rotation = -Math.PI/3;
		s4.buildFromMovieClip(mv, 2);
	
		as.add(s);
		as.add(s2);
		as.add(s3);
		as.add(s4);
		addGraphic(as);
		as.x = 303;
		as.y = 100;
		as.play("left");
	}

	override public function update()
	{
		
		if (Input.pressed(Key.LEFT)) {
			as.play("left");
		}
		if (Input.pressed(Key.UP)) {
			as.play("up");
		}
		if (Input.pressed(Key.RIGHT)) {
			as.play("right");
		}
		if (Input.pressed(Key.DOWN)) {
			as.play("down");
		}
		
		if (Input.pressed(Key.ESCAPE)) {
			HXP.scene = WelcomeWorld.instance;
		}
		
		super.update();
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