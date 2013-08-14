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
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Matrix;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import motion.Actuate;

class LanguageButton extends Scalable
{
	
	var on_click:Dynamic;
	var img2:BitmapData;

	public function new(_bitmap_data:BitmapData, _text:String, _on_click:Dynamic) 
	{
		super();
		
		img2 = new BitmapData(_bitmap_data.width * 5, _bitmap_data.height * 5, false, 0xff000000);
		var matrix:Matrix = new Matrix();
		matrix.identity();
		matrix.scale(5, 5);
		img2.draw(_bitmap_data, matrix);
		
		addChild(new Bitmap(img2));
		
		var text_format:TextFormat = new TextFormat("Arial", 16);
		text_format.align = TextFormatAlign.CENTER;
		
		var tf:TextField = new TextField();
		tf.defaultTextFormat = text_format;
		tf.width = img2.width;
		tf.height = 25;
		tf.y = img2.height + 5;
		tf.text = _text;
		tf.selectable = false;
		tf.mouseEnabled = false;
		addChild(tf);
		
		on_click = _on_click;
		
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		if (on_click != null) on_click();
	}
	
	override private function onMouseOver(e:MouseEvent):Void 
	{
		super.onMouseOver(e);
		parent.setChildIndex(this, parent.numChildren - 1);
	}
	
	public function hide() 
	{
		mouseEnabled = false;
		Actuate.tween(this, 1, { alpha:0 } ).onComplete(unload);
	}
	
	function unload() 
	{
		parent.removeChild(this);
		img2.dispose();
	}
	
}