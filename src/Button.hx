/*
 * Endurance Logger, program that is intended to help your to track your fitness progress
 * Copyright (C) 2013 AS3Boyan
 * 
 * This file is part of Endurance Logger.
 * Endurance Logger is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Endurance Logger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Endurance Logger.  If not, see <http://www.gnu.org/licenses/>.
*/

package ;

import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import motion.Actuate;

class Button extends Sprite
{
	var tf:TextField;
	var background:Sprite;
	var start_x:Float;
	var start_y:Float;
	var on_click:Dynamic;
	public var exercise_type:Int;
	public var time_range:Int;
	var pos_x:Float;
	var pos_y:Float;
	var selection:Sprite;
	
	public function new(_parent:Sprite, _x:Float, _y:Float, _text:String, f:Dynamic=null) 
	{
		super();
		
		background = new Sprite();
		addChild(background);
		
		var text_format:TextFormat = new TextFormat();
		text_format.font = "Arial";
		text_format.align = TextFormatAlign.CENTER;
		
		tf = new TextField();
		tf.selectable = false;
		tf.mouseEnabled = false;
		tf.antiAliasType = AntiAliasType.ADVANCED;
		tf.width = background.width;
		tf.defaultTextFormat = text_format;
		tf.text = _text;
		tf.height = background.height;
		tf.y = (tf.height - tf.textHeight) / 2;
		addChild(tf);
		
		useHandCursor = true;
		buttonMode = true;
		exercise_type = -1;
		time_range = -1;
		
		addEventListener(MouseEvent.CLICK, onClick);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		
		pos_x = _x;
		pos_y = _y;
				
		_parent.addChild(this);
		
		if (f != null) on_click = f;
	}
	
	private function onMouseOut(e:MouseEvent):Void 
	{
		Actuate.tween(this, 1, { x:start_x, y:start_y, scaleX:1, scaleY:1 }, false );
	}
	
	private function onMouseOver(e:MouseEvent):Void 
	{		
		Actuate.tween(this, 1, { x:start_x - width * 0.1, y:start_y - height * 0.1, scaleX:1.2, scaleY:1.2 }, false );
		parent.setChildIndex(this, parent.numChildren - 1);
		
		if (exercise_type != -1 && GV.exercise_type != exercise_type) 
		{
			GV.exercise_type = exercise_type;
			GV.updateData();
		}
		else if (time_range != -1 && GV.time_range != time_range)
		{
			GV.time_range  = time_range;
			GV.updateData();
		}
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		if (on_click != null) on_click();
	}
	
	public function setWidth(?_width:Int=150, ?_height:Int=50, ?_color:Int=-1, ?_selection_thickness:Int=1):Void
	{
		background.addChild(new ColoredRect(_width, _height, _color));
		tf.width = background.width;
		tf.height = background.height;
		tf.y = (tf.height - tf.textHeight) / 2;
		
		x = pos_x - width / 2;
		y = pos_y - height / 2;
		
		start_x = x;
		start_y = y;
		
		selection = new Sprite();
		selection.graphics.lineStyle(_selection_thickness, 0x000000, 0.3);
		selection.graphics.drawRect(0, 0, _width, _height);
		selection.visible = false;
		background.addChild(selection);
	}
	
	public function setSelected(_value:Bool):Void
	{
		selection.visible = _value;
	}
}