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
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.Lib;
import flash.net.URLRequest;
import openfl.Assets;

class SocialButton extends Scalable
{
	var url:String;
	
	public function new(_image_path:String, _url:String) 
	{
		super();
		
		url = _url;
		
		addChild(new Bitmap(Assets.getBitmapData(_image_path),PixelSnapping.AUTO, true));
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function setPos(_x:Float, _y:Float) 
	{
		x = _x;
		y = _y;
		
		start_x = _x;
		start_y = _y;
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		Lib.getURL(new URLRequest(url));
	}
	
}