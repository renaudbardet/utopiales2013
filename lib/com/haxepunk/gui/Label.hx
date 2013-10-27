package com.haxepunk.gui;

import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.HXP;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import tools.display.ColorConverter;
import tools.display.RGB;


/**
 * @author PigMess
 * @author Rolpege
 * @author Lythom
 */
class Label extends Control
{
	var rgb:RGB;
	static public inline var ADDED_TO_CONTAINER:String = "added_to_container";
	static public inline var REMOVED_FROM_CONTAINER:String = "removed_from_container";
	static public inline var ADDED_TO_WORLD:String = "added_to_world";
	static public inline var REMOVED_FROM_WORLD:String = "removed_from_world";
	static public inline var HIDDEN:String = "hidden";
	static public inline var SHOWN:String = "shown";
	static public inline var MOUSE_HOVER:String = "mouseHover";
	static public inline var MOUSE_OUT:String = "mouseOut";
	static public inline var RESIZED:String = "resized";


	/**
	 * Label default font (must be a flash.text.Font object).
	 * Label defaults parameters affect every components that uses labels, i.e. : Button, ToggleButton, CheckBox, RadioButton, MenuItem, Window.
	 * Those labels are always accessible using "myComponent.label" and you can change specific Labels apperence any time.
	 */
	public static var defaultFont:Font = openfl.Assets.getFont("font/04B_03__.ttf");
	//public static var defaultFont:Font = openfl.Assets.getFont("font/pf_ronda_seven.ttf");
	/**
	 * Label default Size.
	 * Label defaults parameters affect every components that uses labels, i.e. : Button, ToggleButton, CheckBox, RadioButton, MenuItem, Window.
	 * Those labels are always accessible using "myComponent.label" and you can change specific Labels apperence any time.
	 */
	public static var defaultSize:Float = 8;
	/**
	 * Label defaultColor. Tip inFlashDevelop : use ctrl + shift + k to pick a color.
	 * Label defaults parameters affect every components that uses labels, i.e. : Button, ToggleButton, CheckBox, RadioButton, MenuItem, Window.
	 * Those labels are always accessible using "myComponent.label" and you can change specific Labels apperence any time.
	 */
	public static var defaultColor:Int = 0x333333;

	/**
	 * Create a text Label printed on a transparent background.
	 * @param	text
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	height
	 * @param	?align
	 */
	public function new(text:String = "", x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0, ?align:FormatAlign)
	{
		_format = new TextFormat(Label.defaultFont.fontName, Label.defaultSize);
		_format.color = Label.defaultColor;

		_textField = new TextField();
		_textField.text = text;
		_textField.defaultTextFormat = _format;
		_textField.selectable = false;
		_textField.embedFonts = true;
		_textField.maxChars = 0;
		_textField.wordWrap = false;
		_textField.multiline = false;
		_textField.setTextFormat(_format);
		_textField.autoSize = TextFieldAutoSize.LEFT;

		// auto set width
		if (width == 0) {
			_autoWidth = true;
			width = Std.int(_textField.textWidth + 4);
		}
		// auto set height
		if (height == 0) {
			_autoHeight = true;
			height = Std.int(_textField.textHeight + 4);
		}

		_renderRect = new Rectangle(0, 0, width, height);
		_textBuffer = HXP.createBitmap(width, height, true);
		graphic = new Stamp(_textBuffer);

		super(x, y, width, height);
		this.align = align;
		
		rgb = new RGB();
	}

	override public function added()
	{
		super.added();
		updateBuffer();
	}

	override public function render()
	{
		if (toBeRedraw) {
			_textBuffer.fillRect(_renderRect, HXP.blackColor);
			if (shadowColor != null) {
				var m:Matrix = new Matrix();
				m.tx = 1;
				m.ty = 1;
				ColorConverter.setRGB(shadowColor, this.rgb);
				_textBuffer.draw(_textField, m, new ColorTransform(0, 0, 0, 1, rgb.r * 255, rgb.g * 255, rgb.b * 255, 0));
				if (shadowBorder) {
					m.tx = -1;
					m.ty = -1;
					_textBuffer.draw(_textField, m, new ColorTransform(0, 0, 0, 1, rgb.r * 255, rgb.g * 255, rgb.b * 255, 0));
					m.tx = 1;
					m.ty = -1;
					_textBuffer.draw(_textField, m, new ColorTransform(0, 0, 0, 1, rgb.r * 255, rgb.g * 255, rgb.b * 255, 0));
					m.tx = -1;
					m.ty = 1;
					_textBuffer.draw(_textField, m, new ColorTransform(0, 0, 0, 1, rgb.r * 255, rgb.g * 255, rgb.b * 255, 0));
				}
			}
			_textBuffer.draw(_textField);
			toBeRedraw = false;
		}
		super.render();
	}

	/**
	 * Call this if width or height is changed manually to update the graphic.
	 */
	public function updateBuffer() {

		// Label has been changed, we need to update its display by drawing it
		toBeRedraw = true;

		// apply new TextFormat to the textField
		_textField.setTextFormat(_format);
		_textField.autoSize = TextFieldAutoSize.LEFT;

		// flag to know if we need to resize Label's buffer.
		var doResize:Bool = false;

		// auto resize width
		if (_autoWidth && width != Std.int(_textField.textWidth + 4)) {
			width = Std.int(_textField.textWidth + 4);
			_textField.width = width;
			_renderRect.width = width;
			doResize = true;
		}

		// auto resize height
		if (_autoHeight && height != Std.int(_textField.textHeight + 4)) {
			height = Std.int(_textField.textHeight + 4);
			_textField.height = height;
			_renderRect.height = height;
			doResize = true;
		}

		if (doResize) {
			_textBuffer = HXP.createBitmap(width, height, true);
			graphic = new Stamp(_textBuffer);
		}
		// alignment
		if (align == TextFormatAlign.CENTER) {
			_alignOffset = Math.round((width - _textField.width)/2);
		} else if (align == TextFormatAlign.RIGHT) {
			_alignOffset = Math.round(width - _textField.width);
		} else {
			_alignOffset = 0;
		}
		graphic.x = Math.round(_alignOffset);
		graphic.y = Math.round((height - _textField.height)/2);
	}

	/**
	 * update or get the text.
	 */
	public var text(get_text, set_text):String;
	private function get_text():String { return _textField.text; }
	private function set_text(value:String):String {
		_textField.text = value;
		updateBuffer();
		return value;
	}

	/**
	 * update or get the text color.
	 */
	public var color(get_color, set_color):Int;
	private function get_color():Int { return _format.color; }
	private function set_color(value:Int):Int {
		_normalColor = value;
		_format.color = value;
		updateBuffer();
		return value;
	}

	/**
	 * get text length.
	 */
	public var length(get_length, never):Int;
	private function get_length():Int { return _textField.text.length; }

	/**
	 * update or get text size.
	 */
	public var size(get_size, set_size):Dynamic;
	private function get_size():Dynamic { return _format.size; }
	private function set_size(value:Dynamic):Dynamic {
		_format.size = value;
		updateBuffer();
		return value;
	}

	/**
	 * update or get font
	 */
	public var font(get_font, set_font):String;
	private function get_font():String { return _format.font; }
	private function set_font(value:String):String {
		_format.font = value;
		updateBuffer();
		return value;
	}

	/**
	 * update or get text alignement.
	 * No effect if autoWidth is true.
	 */
	public var align(default, set_align):FormatAlign;
	private function set_align(value:FormatAlign):FormatAlign {
		_format.align = value ;
		updateBuffer();
		return value;
	}
	
	public var alpha(get_alpha, set_alpha):Float;
	private function get_alpha():Float {
		return _textField.alpha;
	}
	private function set_alpha(value:Float):Float {
		_textField.alpha = value;
		updateBuffer();
		return value;
	}

	/**
	 * Automatically resize Label height.
	 */
	public var autoHeight(get_autoHeight, set_autoHeight):Bool;
	private function get_autoHeight():Bool
	{
		return _autoHeight;
	}
	private function set_autoHeight(value:Bool):Bool
	{
		_autoHeight = value;
		return _autoHeight;
	}

	/**
	 * Automatically resize Label width.
	 */
	public var autoWidth(get_autoWidth, set_autoWidth):Bool;
	private function get_autoWidth():Bool
	{
		return _autoWidth;
	}
	private function set_autoWidth(value:Bool):Bool
	{
		_autoWidth = value;
		return _autoWidth;
	}

	private function get_disabledColor():Int
	{
		return _disabledColor;
	}
	private function set_disabledColor(value:Int):Int
	{
		return _disabledColor = value;
	}
	/**
	 * Text color to use when disabled.
	 * Mostly used when Label is used as child of another component.
	 */
	public var disabledColor(get_disabledColor, set_disabledColor):Int;
	
	function get_shadowColor():Null<UInt>
	{
		return _shadowColor;
	}
	
	function set_shadowColor(value:Null<UInt>):Null<UInt>
	{
		return _shadowColor = value;
	}
	
	public var shadowColor(get_shadowColor, set_shadowColor):Null<UInt>;
	
	override private function set_enabled(value:Bool):Bool
	{
		if (value) {
			_format.color = _normalColor;
		} else {
			_format.color = _disabledColor;
		}
		updateBuffer();
		return super.set_enabled(value);
	}

	override public function toString():String
	{
		return this._class + "=" + this.text;
	}

	private var _textField:TextField;
	private var _renderRect:Rectangle;
	private var _textBuffer:BitmapData;
	private var _format:TextFormat;
	private var _autoHeight:Bool = false;
	private var _autoWidth:Bool = false;
	private var _disabledColor:Int = 0x666666;
	private var _normalColor:Int;
	private var toBeRedraw:Bool = true;
	private var _alignOffset:Int = 0;
	private var _shadowColor:Null<UInt> = null;
	public var shadowBorder:Bool = false;
}