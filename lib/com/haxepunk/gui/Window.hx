package com.haxepunk.gui;
import com.haxepunk.Graphic;
import com.haxepunk.gui.Button;
import com.haxepunk.gui.graphic.NineSlice;
import com.haxepunk.gui.Label;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.text.TextFormatAlign;


/**
 * ...
 * @author Samuel Bouchet
 */
class Window extends Panel
{
	private var label:Label;
	private var _title:String;
	private var _drag:Bool;
	private var _lastMouseX:Int;
	private var _lastMouseY:Int;
	private var _mouseStartX:Float;
	private var _mouseStartY:Float;

	static public inline var ADDED_TO_CONTAINER:String = "added_to_container";
	static public inline var REMOVED_FROM_CONTAINER:String = "removed_from_container";
	static public inline var ADDED_TO_WORLD:String = "added_to_world";
	static public inline var REMOVED_FROM_WORLD:String = "removed_from_world";
	static public inline var HIDDEN:String = "hidden";
	static public inline var SHOWN:String = "SHOWN";
	static public inline var MOUSE_HOVER:String = "mouseHover";
	static public inline var MOUSE_OUT:String = "mouseOut";
	static public inline var RESIZED:String = "resized";

	private var windowHeader:Graphic;
	private var _closeButton:Bool;
	private var closeButtonControl:Button;

	/**
	 * Create a Window Panel movable with mouse and having a title.
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @param	title
	 */
	public function new(title:String = "Window 1", x:Float = 0, y:Float = 0, width:Int = 1, height:Int = 1)
	{
		_closeButton = false ;
		_title = title;
		// 24x24 squares composed of 9 8x8 slices
		if (background == null) {
			background = new NineSlice(width, height, new Rectangle(72, 0, 8, 8));
		}
		if (windowHeader == null) {
			windowHeader = new NineSlice(width, 24, new Rectangle(72, 24, 8, 8));
			windowHeader.y = -16;
			// 3 top tiles of background are overwritten, blank them to prevent overlay problems
			background.hideTop();
		}

		super(x, y, width, height);
		addGraphic(windowHeader);

		label = new Label(_title, 0, -16, width, 16, TextFormatAlign.CENTER);
		label.color = 0x000000;
		addControl(label);

		closeButtonControl = new Button("X", 0, 0, 16, 16);
		closeButtonControl.padding = 0;
		closeButtonControl.localX = this.width - closeButtonControl.width ;
		closeButtonControl.localY = - closeButtonControl.height;
		if (_closeButton) {
			addControl(closeButtonControl);
			closeButtonControl.show();
		} else {
			closeButtonControl.hide();
		}
	}

	override public function added()
	{
		closeButtonControl.addEventListener(Button.CLICKED, hide);
		super.added();
	}

	override public function removed():Void
	{
		closeButtonControl.removeEventListener(Button.CLICKED, hide);
		super.removed();
	}

	override public function show(?e:Event):Void
	{
		super.show(e);
		if (!_closeButton) {
			closeButtonControl.hide();
		}
	}

	override public function updateSize(?e:Event):Void
	{
		super.updateSize();
		cast(windowHeader, NineSlice).width = width;
	}

	override private function updateChildPosition()
	{
		super.updateChildPosition();
	}

	override public function update()
	{
		if (_enabled) {
			if (Input.mouseDown
				&& scene != null && isChild(scene.collidePoint(this.type, Input.mouseX + HXP.camera.x, Input.mouseY + HXP.camera.y))
				&& Input.mouseX + HXP.camera.x >= absoluteX && Input.mouseX + HXP.camera.x <= absoluteX + width
				&& Input.mouseY + HXP.camera.y <= absoluteY && Input.mouseY + HXP.camera.y >= absoluteY - 16
				&& !_drag ) {

				_drag = true;
				// record the position of the mouse where the drag started in the scene
				// if followCamera is TRUE, window position is relative to the SCREEN
				// if !followCamera is FALSE, window position is relative to the scene
				// if is a child, make the position relative to the container in case the container moves
				_mouseStartX = Input.mouseX + (followCamera||container!=null?0:HXP.camera.x) - _localX;
				_mouseStartY = Input.mouseY + (followCamera||container!=null?0:HXP.camera.y) - _localY;
			}

			if (Input.mouseUp) {
				_drag = false;
			}

			if (_drag) {
				// place the window at the mouse position
				// if followCamera is TRUE, place the window relative to the SCREEN
				// if !followCamera is FALSE, place the window relative to the SCENE
				this.localX = (Input.mouseX + (followCamera||container!=null?0:HXP.camera.x) - _mouseStartX);
				this.localY = (Input.mouseY + (followCamera||container!=null?0:HXP.camera.y) - _mouseStartY);
			}
		}

		closeButtonControl.label.localX = 0;
		closeButtonControl.label.localY = 0;

		super.update();
	}

	private function get_title():String
	{
		return _title;
	}

	private function set_title(value:String):String
	{
		return _title = value;
	}

	public var title(get_title, set_title):String;

	private function get_closeButton():Bool
	{
		return _closeButton;
	}

	private function set_closeButton(value:Bool):Bool
	{
		if (value) {
			if (this.visible) {
				closeButtonControl.show();
			}
		} else {
			closeButtonControl.hide();
		}
		return _closeButton = value;
	}

	public var closeButton(get_closeButton, set_closeButton):Bool;

}