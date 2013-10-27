package com.haxepunk.gui;

import com.haxepunk.Graphic;
import com.haxepunk.graphics.Image;
import com.haxepunk.gui.Control;
import com.haxepunk.gui.event.ControlEvent;

/**
 * Ideal item to be displayed in a MenuList.
 * @author Lythom
 */
class MenuItem extends Control
{
	/**
	 * Space between icon and Label in px.
	 */
	static public inline var defaultIcon2LabelSpacing:Int = 2;
	/**
	 * Space between Label and Quantity count in px.
	 * Used when width is auto calculated (set to 0). if width is fixed, quantity is displayed on the right side.
	 */
	static public inline var defaultLabel2QuantitySpacing:Int = 5;

	private var _label:Label;
	private var _quantityLabel:Label;
	private var _icon:Image;
	private var _quantity:Int;
	private var label2QuantitySpacing:Int;
	private var icon2LabelSpacing:Int;

	/**
	 * Ideal item to be displayed in a MenuList with optional icon and optional quantity count.
	 *
	 * @param	label		Label describing the item
	 * @param	icon		icon to display in front of the label
	 * @param	quantity	numbers of this item. Display a final "x<quantity>" if <quantity> > 0.
	 * @param 	x			x/localX position of the component
	 * @param 	y			y.localY position of the component
	 * @param 	width 		Width of the component
	 * @param 	height 		Height of the component
	 */
	public function new(label:String = "Item", icon:Image = null, quantity:Int=0, x:Float = 0, y:Float = 0, width:Int = 0, height:Int = 0) {
		super(x, y, width, height);
		
		label2QuantitySpacing = defaultLabel2QuantitySpacing;
		icon2LabelSpacing = defaultIcon2LabelSpacing;

		_icon = icon;
		_quantity = quantity;
		_quantityLabel = new Label("x"+_quantity);

		// calculate remaining space for the Label into the MenuItem if width is not auto (>0)
		var labelWidth = calculateLabelWidth();
		_label = new Label(label, 0, 0, labelWidth, height);

		if (hasIcon()) {
			addGraphic(_icon);
		}
		addControl(_label);
		if (hasQuantity()) {
			addControl(_quantityLabel);
		}

		updateSize();
	}

	override public function added()
	{
		_quantityLabel.addEventListener(Label.RESIZED, updateSize);
		_label.addEventListener(Label.RESIZED, updateSize);
		updateSize();
		super.added();
	}

	override public function removed():Void
	{
		_quantityLabel.removeEventListener(Label.RESIZED, updateSize);
		_label.removeEventListener(Label.RESIZED, updateSize);
		super.removed();
	}

	private function updateSize(?e:ControlEvent)
	{
		// set height automatically if height was set to "auto" (0)
		if (_label.autoHeight) {
			height = _label.height ;
		}
		// recalculate label width now that parent size may have changed
		if (Std.is(this.container, MenuList)) {
			var parent = cast(this.container, MenuList);
			this.width = parent.width - parent.padding * 2;
			this.label.width = calculateLabelWidth();
		}
		// set icon and label positions
		if (hasIcon()) {
			if (_label.autoHeight && _icon.height > this.height) {
				height = _icon.height ;
			}
			_icon.x = 0;
			_icon.y = this.halfHeight - _icon.height/2;
			_label.localX = _icon.x + _icon.width + icon2LabelSpacing;
		} else {
			_label.localX = 0 ;
		}
		_label.localY = this.halfHeight - _label.halfHeight;

		// set quantity position
		if (hasQuantity()) {
			// if width is autoCalculated, put elements side by side
			if (_label.autoWidth) {
				_quantityLabel.localX = _label.localX + _label.width + label2QuantitySpacing;

			// if fixed width, _quantity will be displayed to the right
			} else {
				_quantityLabel.localX = width - _quantityLabel.width;
			}
			_quantityLabel.localY = 0;
		}

		// set width automatically if width was set to "auto" (0)
		if (_label.autoWidth) {
			if (hasQuantity()) {
				width = Math.ceil(_quantityLabel.localX + _quantityLabel.width);
			} else {
				width = Math.ceil(_label.localX + _label.width);
			}
		}
	}

	/**
	 * Do we have to display quantity ?
	 * @return
	 */
	public function hasQuantity():Bool
	{
		return _quantity > 0;
	}

	/**
	 * Do we have to display icon ?
	 * @return
	 */
	public function hasIcon():Bool
	{
		return _icon != null;
	}


	private function get_label():Label
	{
		return _label;
	}

	private function set_label(value:Label):Label
	{
		return _label = value;
	}
	/**
	 * Item label
	 */
	public var label(get_label, set_label):Label;

	private function get_icon():Image
	{
		return _icon;
	}

	private function set_icon(value:Image):Image
	{
		return _icon = value;
	}
	/**
	 * Item icon.
	 * It's an Image and not a Graphic because Graphic doesn't support height and width.
	 */
	public var icon(get_icon, set_icon):Image;


	private function get_quantityLabel():Label
	{
		return _quantityLabel;
	}

	private function set_quantityLabel(value:Label):Label
	{
		return _quantityLabel = value;
	}
	/**
	 * Label used to display quantity.
	 * Customize quantity display using this.
	 */
	public var quantityLabel(get_quantityLabel, set_quantityLabel):Label;

	private function get_quantity():Int
	{
		return _quantity;
	}

	private function set_quantity(value:Int):Int
	{
		_quantityLabel.text = "x" + value;
		return _quantity = value;
	}

	public var quantity(get_quantity, set_quantity):Int;

	/**
	 * Automatically resize height.
	 */
	public var autoHeight(get_autoHeight, set_autoHeight):Bool;
	private function get_autoHeight():Bool
	{
		return _label.autoHeight;
	}
	private function set_autoHeight(value:Bool):Bool
	{
		return _label.autoHeight = value;
	}

	/**
	 * Automatically resize width.
	 */
	public var autoWidth(get_autoWidth, set_autoWidth):Bool;
	private function get_autoWidth():Bool
	{
		return _label.autoWidth;
	}
	private function set_autoWidth(value:Bool):Bool
	{
		return _label.autoWidth = value;
	}
	
	private function calculateLabelWidth():Int 
	{
		var labelWidth:Int = 0;
		if (width > 0) {
			labelWidth = width;
			if (hasIcon()) {
				labelWidth -= _icon.width + icon2LabelSpacing;
			}
			if (hasQuantity()) {
				labelWidth -= _quantityLabel.width + label2QuantitySpacing;
			}
		}
		return labelWidth;
	}


}