package com.haxepunk.gui;

import com.haxepunk.gui.Control;
import com.haxepunk.gui.event.ControlEvent;
import com.haxepunk.gui.tween.CarouselTween;
import com.haxepunk.HXP;
import com.haxepunk.Tween;
import com.haxepunk.utils.Input;

/**
 * Carousel component, ables to display children in a wheel. The selected one only is enabled and
 * is displayed in front of the others.
 * @author Lythom
 */
class Carousel extends Control
{
	static public inline var ADDED_TO_CONTAINER:String = "added_to_container";
	static public inline var REMOVED_FROM_CONTAINER:String = "removed_from_container";
	static public inline var ADDED_TO_WORLD:String = "added_to_world";
	static public inline var REMOVED_FROM_WORLD:String = "removed_from_world";
	static public inline var HIDDEN:String = "hidden";
	static public inline var SHOWN:String = "shown";
	static public inline var CLICKED:String = "clicked";
	static public inline var MOUSE_HOVER:String = "mouseHover";
	static public inline var MOUSE_OUT:String = "mouseOut";
	static public inline var RESIZED:String = "resized";
	static public inline var SELECTION_CHANGED:String = "selectionChanged";

	/**
	 * Drag and drop rotation speed
	 */
	static public inline var DRAG_SPEED:Float = 2;

#if haxe3
	private var angles:Map<String,Float>;
	private var tweens:Map<String,CarouselTween>;
#else
	private var angles:Hash<Float>;
	private var tweens:Hash<CarouselTween>;
#end
	private var wheelWidth:Int;
	private var wheelHeight:Int;
	private var _selectedId:Int;
	private var direction:String ;

	private var startDrag:Bool;
	private var mouseLastX:Int;
	private var orderedControls:Array<Control>;
	private var _allowDragToRoll:Bool;

	/**
	 * When using fixed framerate, number of frames needed to complete selectNext() or selectPrevious() animation.
	 */
	public var fixedRotationDurationInFrames:Int = 20;
	/**
	 * When using non fixed framerate, number of seconds needed to complete selectNext() or selectPrevious() animation.
	 */
	public var nonFixedRotationDurationInSeconds:Float = 0.3;

	/**
	 * Create a Carousel component, ables to display children in a wheel. The selected one only is enabled and
	 * is displayed in front of the others.
	 * @param	x		x/localX pos of the carousel
	 * @param	y		y/localY pos of the carousel
	 * @param	width	width of the carousel eliptic rail. Controls are centered on the rail.
	 * @param	height  height of the carousel eliptic rail. Controls are centered on the rail.
	 */
	public function new(x:Float = 0, y:Float = 0, width:Int=300, height:Int=100)
	{
		super(x, y, width, height);
		wheelWidth = this.width;
		wheelHeight = this.height;
		_selectedId = 0;
#if haxe3
		angles = new Map<String,Float>();
		tweens = new Map<String,CarouselTween>();
#else
		angles = new Hash<Float>();
		tweens = new Hash<CarouselTween>();
#end
		startDrag = false;
		_allowDragToRoll = true;
	}

	/**
	 * Rotate the carousel to select the next element (on the right of the current)
	 */
	public function selectNext()
	{
		if (children.length > 0) {
			_selectedId = (selectedId + 1) % children.length;
		}
		direction = CarouselTween.COUNTER_CLOCKWISE;
		calculateChildrenPositions();
		dispatchEvent(new ControlEvent(this, SELECTION_CHANGED));
	}

	/**
	 * Rotate the carousel to select the previous element (on the left of the current)
	 */
	public function selectPrevious()
	{
		if (children.length > 0) {
			_selectedId = (_selectedId - 1) % children.length;
			if (_selectedId < 0) {
				_selectedId += children.length;
			}
		}
		direction = CarouselTween.CLOCKWISE;
		calculateChildrenPositions() ;
		dispatchEvent(new ControlEvent(this, SELECTION_CHANGED));
	}

	/**
	 * Add a control to display on the carousel
	 * @param	child
	 */
	override public function addControl(child:Control, ?position:Int):Void
	{
		super.addControl(child);
		// some dirty thing (sorry) to have unique id for objects.
		if (child.name == "" || angles.exists(child.name)) {
			child.name += "c";
			while (angles.exists(child.name )) {
				child.name += "c";
			}
		}
		angles.set(child.name, 0.0);
		tweens.set(child.name, new CarouselTween(null, TweenType.Persist));
		addTween(tweens.get(child.name));

		orderedControls = this.children.copy();
		direction = CarouselTween.COUNTER_CLOCKWISE;
		calculateChildrenPositions();
	}

	/**
	 * Remove a control from the carousel
	 * @param	child
	 */
	override public function removeControl(child:Control):Void
	{
		if (angles.exists(child.name)) {
			angles.remove(child.name);
		}
		if (tweens.exists(child.name)) {
			removeTween(tweens.get(child.name));
			tweens.remove(child.name);
		}
		super.removeControl(child);

		orderedControls = this.children.copy();
		direction = CarouselTween.CLOCKWISE;
		calculateChildrenPositions();
	}

	override public function update()
	{
		if (children.length > 1) {

			// check the mouse effect zone has been clicked
			if (Input.mousePressed
				&& collidePoint(absoluteX, absoluteY, Input.mouseX + HXP.camera.x, Input.mouseY + HXP.camera.y) && allowDragToRoll)
			{
				startDrag = true;
				mouseLastX = Input.mouseX;
			}

			// release to stop drag
			if (Input.mouseReleased && startDrag) {
				startDrag = false;
				selectedId = Lambda.indexOf(children, orderedControls[0]);
			}

			// do drag if mouse down
			if (startDrag) {
				doDrag();
			}
		}

		super.update();
	}

	/**
	 * Update childs to display them on the wheel.
	 * @return
	 */
	override private function updateChildPosition()
	{
		for (c in children)
		{
			c.localX = Math.round((wheelWidth / 2) * (Math.cos(tweens.get(c.name).angle)+1) - c.halfWidth);
			c.localY = Math.round((wheelHeight / 2) * (-Math.sin(tweens.get(c.name).angle)+1) -c.halfHeight);
			c.x = c.absoluteX;
			c.y = c.absoluteY;
			c.updateChildPosition();
		}
	}

	/**
	 * calculate future position after the move and initiate the move
	 */
	private function calculateChildrenPositions()
	{
		var angleDiff:Float = Math.PI * 2 / children.length;
		var angle:Float = 0 ;
		for (iChild in 0...children.length)
		{
			var c:Control = children[iChild];
			// angle of the child in the Carousel wheel
			//		angle     *  relative index       - 90° to have it on the front
			angle = angleDiff * (iChild - _selectedId) - Math.PI / 2;
			// swmooth move to mosition
			tweens.get(c.name).tween(tweens.get(c.name).angle % (Math.PI * 2), angle % (Math.PI * 2), direction, HXP.fixed?fixedRotationDurationInFrames:nonFixedRotationDurationInSeconds);
			// save angle
			angles.set(c.name, angle);
			// only enable selected Control
			if (iChild == _selectedId) {
				c.enabled = true ;
			} else {
				c.enabled = false;
			}
		}
		// use angles to order correctly on Z axis
		orderChildrenLayers();

	}

	/**
	 * after changing layer, recalculate children layers
	 * @param	value
	 * @return
	 */
	override private function set_layer(value:Int):Int
	{
		var lay:Int = super.set_layer(value);
		if (this._children != null) {
			orderChildrenLayers();
		}
		return lay;
	}

	/**
	 * Affect a new layer to each child according to it's position in the wheel.
	 */
	private function orderChildrenLayers():Void
	{
		var layerIndex:Int = this.layer - getNeededDepth();
		if(orderedControls != null){
			// sort by sin position
			orderedControls.sort(controlCompare);
			// affect layers depending on needed depth for each control
			for (c in orderedControls) {
				layerIndex += c.depth;
				if (c.layer != layerIndex) {
					c.layer = layerIndex;
				}
			}
		}
	}

	private function controlCompare(c1:Control, c2:Control):Int {
		return (Math.sin(angles.get(c1.name)) > Math.sin(angles.get(c2.name))) ? 1 : -1;
	}

	/**
	 * The number of layers needed so that each component have enough layer to be entierly displayed ordered.
	 * @return
	 */
	private function getNeededDepth():Int {
		var totalDepthNeeded:Int = 1;
		for (c in children)
		{
			// increase neededDepth
			totalDepthNeeded += c.depth;
		}
		return totalDepthNeeded;
	}

	override private function get_depth():Int
	{
		return getNeededDepth();
	}

	private function doDrag():Void
	{
		var d:Int = Math.ceil(Input.mouseX - mouseLastX);
		if (d != 0) {
			for (c in children) {
				tweens.get(c.name).tween(tweens.get(c.name).angle, tweens.get(c.name).angle + (d / (this.width / DRAG_SPEED)), CarouselTween.COUNTER_CLOCKWISE, HXP.fixed?1:0.001);
				angles.set(c.name, tweens.get(c.name).angle);
			}
		}
		mouseLastX = Input.mouseX;
		orderChildrenLayers();
	}

	private function get_selectedId():Int
	{
		return _selectedId;
	}

	private function set_selectedId(value:Int):Int
	{
		if (value >= 0 && value < children.length) {
			_selectedId = value;
			direction = CarouselTween.AUTO;
			calculateChildrenPositions() ;
			dispatchEvent(new ControlEvent(this, SELECTION_CHANGED));
		}
		return _selectedId;
	}
	/**
	 * set or get the id of the selected (front) element in the wheel.
	 */
	public var selectedId(get_selectedId, set_selectedId):Int;

	private function get_allowDragToRoll():Bool
	{
		return _allowDragToRoll;
	}

	private function set_allowDragToRoll(value:Bool):Bool
	{
		return _allowDragToRoll = value;
	}

	public var allowDragToRoll(get_allowDragToRoll, set_allowDragToRoll):Bool;

}