package com.gigglingcorpse.utils;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;

/**
 * A simple profiler.  Instantiate it and add it to the stage.
 * From then on you can refer to it through its class name (Profiler).
 * Requires that the debug flag be set, that way I can leave the calls in my code and not worry about it.
 *
 * @author brad
 */

class Profiler extends Sprite
{
	
	#if debug
	
	private static inline var graphWidth:Int = 100;
	private static var _instance:Profiler;
	
	// Frame rate tracking
	private var _frameTime:Float;
	private var _frameWindow:Int;
	private var _currentFrame:Int;
	private var _fps:Int;
	private var _fps_spr:TextField;
	
	// How much time the profiler has spent running
	private var _selfTime:Float;
	
	// The code sections data
	private var _sectionMap:Map<String,SectionData>;
	
	private var _onStage:Bool;
	
	// Frame time tracking
	private var _lastTime:Float;
	private var _now:Float;
	
	// When (running) profiler code was started (different from _instancedAt)
	private var _startedAt:Float;
	// When the profiler was instanced/started
	private var _instancedAt:Float;
	
	#end
	
	public function new( ?frameLength:Int ) 
	{
		#if debug
			super();
			_instance = this;
			_instancedAt = Lib.getTimer();
			startThis();
			
			_sectionMap = new Map<String,SectionData>();
			_frameTime = 0;
			_selfTime = 0;
			_now = 0;
			_frameWindow = (frameLength > 0 ) ? frameLength : 10;	
			_lastTime = _instancedAt;
			
			// Setup the text field
			_fps_spr = new TextField();
			var tf = new TextFormat( "_sans", 10, 0x000000 );
			_fps_spr.defaultTextFormat = tf;
			_fps_spr.border = false;
			_fps_spr.background = false;
			_fps_spr.text = "fps: --";
			_fps_spr.width = 100;
			_fps_spr.height = 15;
			_fps_spr.selectable = false;
			addChild( _fps_spr );
			
			// Setup event handlers
			var stage = Lib.current.stage;
			addEventListener( Event.ADDED_TO_STAGE, addedToStage );
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStage );
			stage.addEventListener( Event.ENTER_FRAME, onFrame );
			
			
			stopThis();
			return;
			
		#else
		super();
		#end
	}
	
	// Event handlers
	
	#if debug
	
	private inline function onFrame( e:Event ) {
		startThis();
		_now = Lib.getTimer();
		
		_frameTime += _now - _lastTime;
		_currentFrame = ( _currentFrame + 1 ) % _frameWindow;
		
		if ( _currentFrame == 0 ) {
			_fps = Std.int( _frameWindow / ( _frameTime / 1000.0 ));
			_frameTime = 0;
			if ( _onStage )
				updateGraphics();
		}
		
		_lastTime = _now;
		stopThis();
	}
		
	private inline function addedToStage( e:Event ) {
		_onStage = true;
		updateGraphics();
	}
	
	private inline function removedFromStage( e:Event ) {
		_onStage = false;
	}

	#end
	
	// Custom section tracking functions
	
	
	/**
	 * Starts timing for a section. (It will create the section if it doesn't exist.)
	 * @param	section Your reference string for the section.
	 */
	public static #if !debug inline #end function start( section:String ) {
		#if debug
		startThis();
		if ( !_instance._sectionMap.exists( section ) ) {
			_instance._sectionMap.set( section, new SectionData( section ) );
		} else _instance._sectionMap.get( section ).start();
		_instance.stopThis();
		#end
	}
	
	
	/**
	 * Stops timing for a section.
	 * @param	section Your reference string for the section.
	 * @return	If the section exists.
	 */
	public static #if !debug inline #end function stop( section:String ) : Bool{
		#if debug
		startThis();
		var r = false;
		if ( _instance._sectionMap.exists( section ) ) {
			_instance._sectionMap.get( section ).stop();
			r = true;
		}
		_instance.stopThis();
		return r;
		
		#else
		
		return false;
		#end
	}
	
	
	/**
	 * Returns the total time logged for a section.
	 * @param	section reference string.
	 * @return  time logged.
	 */
	public static #if !debug inline #end function get( section:String ) : Float {
		#if debug
		startThis();
		if ( _instance._sectionMap.exists( section ) ) 
			return _instance._sectionMap.get( section ).time();
		_instance.stopThis();
		
		#end
		return 0;
	}
	
	
	/**
	 * returns the current frames-per-second value.
	 * @return
	 */
	public static inline function fps() : Int {
		#if debug
		return _instance._fps;
		#else
		return -1;
		#end
	}
	
	
	
	// Internal functions
	
	#if debug
	
	private inline function updateGraphics() {
		// Write the FPS
		_fps_spr.text = 'fps: ' + _fps ;
		
		// Calculate the maximum time, for scaling the graphs
		var maxTime = 0.0;
		var totalTime = 0.1;
		for ( section in _sectionMap ) {
			if ( section.time() > maxTime )
				maxTime = section.time();
			totalTime += section.time();
		}
		
		if ( _selfTime > maxTime )
			maxTime = _selfTime;
		//totalTime += _selfTime;
		
		
		// Draw the section data
		graphics.clear();
		var cy = _fps_spr.y + _fps_spr.height + 4;
		for ( section in _sectionMap ) {
			
			// Make sure the label is there
			if ( !contains( section.textField ) ) {
				addChild( section.textField );
				section.textField.y = cy;
				section.textField.x = _fps_spr.x;
			}			
			cy += section.textField.height + 2;
			
			// Graph background ( max time )
			graphics.beginFill( 0x00FF00 );
			graphics.drawRect( section.textField.x + section.textField.width + 2, section.textField.y, Profiler.graphWidth, section.textField.height );
			graphics.endFill();
			
			// Graph foreground ( section time )
			graphics.beginFill( 0xFF0000 );
			graphics.drawRect( section.textField.x + section.textField.width + 2, section.textField.y, (section.time()/totalTime)*Profiler.graphWidth, section.textField.height );
			graphics.endFill();
			
		}
		
		
		// Graph background ( max time )
		graphics.beginFill( 0xAAAAAA );
		graphics.drawRect( _fps_spr.x + 2, cy+5, Profiler.graphWidth + _fps_spr.width, 2 );
		graphics.endFill();
		
		// Graph foreground ( section time )
		graphics.beginFill( 0xFF0000 );
		graphics.drawRect( _fps_spr.x + 2 , cy+5, (totalTime/(Lib.getTimer()-_instancedAt))*(Profiler.graphWidth + _fps_spr.width), 2 );
		graphics.endFill();
	}
	
	
	/**
	 * Start the clock for the internal time log.
	 * This should be called at the beginning of every entry point to the class,
	 * Including event handlers.  (But not in functions who can/will only be 
	 * called from other in-class functions.)
	 */ 
	private static inline function startThis() {
		if ( _instance == null ) 
			_instance = new Profiler();			
		_instance._startedAt = Lib.getTimer();
	}
	
	
	/**
	 * Stop the clock for the internal time log. 
	 * Should be called at the end of every function who calls startThis();
	 */
	private inline function stopThis() {
		_instance._selfTime += Lib.getTimer() - _instance._startedAt;
	}
	
	#end
	
	public static inline function clamp( min:Float, val:Float, max:Float )  : Float {
		return min > val ? min : max < val ? max : val;
	}
	
}

#if debug

class SectionData {
	
	private var section:String;
	private var startTime:Float;
	private var totalTime:Float;
	public var textField:TextField;
	
	public function new( name:String ) {
		section = name;
		totalTime = 0;
		start();
		
		// Setup the text field
		textField = new TextField();
		var tf = new TextFormat( "_sans", 10, 0x000000 );
		textField.defaultTextFormat = tf;
		textField.border = false;
		textField.background = false;
		textField.text = section;
		textField.width = 100;
		textField.height = 15;
		textField.selectable = false;
	}
	
	public inline function stop() {
		totalTime += (Lib.getTimer() - startTime );
	}
	
	public inline function start() {
		startTime = Lib.getTimer();
	}
	
	public inline function time() {
		return totalTime;
	}
	
	public inline function toString() {
		return "\t" + section + ": " + totalTime + "\n";
	}
	
}

#end
