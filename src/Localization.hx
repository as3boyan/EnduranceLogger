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
import flash.display.BitmapData;
import firetongue.Replace;

class Localization
{
	private static var fire_tongue:firetongue.FireTongue;
	
	public static function init():Void
	{
		fire_tongue = new firetongue.FireTongue();
		fire_tongue.init("en-US");
	}
	
	public static function selectLocale(locale:String, ?onLoad:Dynamic = null):Void
	{
		fire_tongue.init(locale, onLoad);
	}
	
	public static function getLocales():Array<String>
	{
		return fire_tongue.locales;
	}
	
	public static function getIcon(locale:String):BitmapData
	{
		return fire_tongue.getIcon(locale);
	}
	 
	public static function get(name:String):String
	{
		return fire_tongue.get(name);
	}
	
	public static function getAndReplace(name:String, value:String):String
	{
		return Replace.flags(fire_tongue.get(name), ["<X>"],[value]);
	}
	
	
}