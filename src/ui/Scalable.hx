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

package ui;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import motion.Actuate;

class Scalable extends Sprite
{
	var start_x:Float;
	var start_y:Float;
	
	public function new() 
	{
		super();
		
		start_x = 1;
		start_y = 1;
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function onAdded(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		#if mobile
		addEventListener(TouchEvent.TOUCH_OUT, onTouchOut);
		addEventListener(TouchEvent.TOUCH_OVER, onTouchOver);
		addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		#else
		
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
		
		useHandCursor = true;
		buttonMode = true;
		#end
	}
	
	private function onTouchEnd(e:TouchEvent):Void 
	{
		onMouseOut(null);
	}
	
	private function onTouchOver(e:TouchEvent):Void 
	{
		onMouseOver(null);
	}
	
	private function onTouchOut(e:TouchEvent):Void 
	{
		onMouseOut(null);
	}
	
	public function setPos(_x:Float, _y:Float):Void 
	{
		x = _x;
		y = _y;
		
		start_x = _x;
		start_y = _y;
	}
	
	private function onMouseOut(e:MouseEvent):Void 
	{
		Actuate.tween(this, 1, { x:start_x, y:start_y, scaleX:1, scaleY:1 }, false );
	}
	
	private function onMouseOver(e:MouseEvent):Void 
	{		
		Actuate.tween(this, 1, { x:start_x - width * 0.1, y:start_y - height * 0.1, scaleX:1.2, scaleY:1.2 }, false );
	}
	
}