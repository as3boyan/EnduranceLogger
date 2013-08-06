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
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import motion.Actuate;

class ProgressBar extends Sprite
{
	var tf:TextField;
	var background:ColoredRect;

	public function new() 
	{
		super();
		
		background = new ColoredRect(800, 12, 0x229ABD);
		addChild(background);
		
		var text_format:TextFormat = new TextFormat("Arial", 8);
		text_format.align = TextFormatAlign.CENTER;
		
		tf = new TextField();
		tf.defaultTextFormat = text_format;
		tf.text = "0";
		tf.width = width;
		tf.height = 12;
		tf.selectable = false;
		addChild(tf);
		
		mouseEnabled = false;
		
		width = 800;
		
		visible = false;
	}
	
	public function setValue(_bytesLoaded, _bytesTotal):Void
	{
		var percent:Float = _bytesLoaded / _bytesTotal;
		background.width = Math.max(percent * 800,1);
		tf.text = Std.string(Std.int(_bytesLoaded / 1024)) + " KB/ " + Std.string(Std.int(_bytesTotal / 1024)) + " KB"; 
	}
	
}