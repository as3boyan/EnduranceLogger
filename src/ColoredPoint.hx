/*
 * Endurance Logger, program that is intended to help you to track your fitness progress
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

import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

class ColoredPoint extends Sprite
{
	var tf:TextField;

	public function new() 
	{
		super();
		
		tf = new TextField();
		tf.y = -50;
		tf.width = 150;
		tf.height = 50;
		tf.multiline = true;
		tf.selectable = false;
		tf.visible = false;
		tf.mouseEnabled = false;
		addChild(tf);
		
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
	}
	
	private function onMouseOver(e:MouseEvent):Void 
	{
		tf.visible = true;
		
		if (x + 150 > stage.stageWidth)
		{
			tf.x = (stage.stageWidth - 150 - x);
		}
		else
		{
			tf.x = 0;
		}
		
		if (y < 100)
		{
			tf.y = 15;
		}
		else
		{
			tf.y = -50;
		}
		
		parent.setChildIndex(this, parent.numChildren - 1);
	}
	
	private function onMouseOut(e:MouseEvent):Void 
	{
		tf.visible = false;
	}
	
	public function setColor(_color:Int, ?_alpha:Float = 1)
	{
		graphics.clear();
		graphics.beginFill(_color);
		graphics.drawCircle(0, 0, 10);
		graphics.endFill();
	}
	
	public function setText(_string:String, _value:Int)
	{
		tf.text = Std.string(_value) + "\n" + _string;
	}
	
}