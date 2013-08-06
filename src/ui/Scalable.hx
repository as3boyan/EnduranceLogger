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
import flash.events.MouseEvent;
import motion.Actuate;

class Scalable extends Sprite
{
	var start_x:Float;
	var start_y:Float;
	
	public function new() 
	{
		super();
		
		addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
		addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
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