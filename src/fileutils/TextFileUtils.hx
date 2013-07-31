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

package fileutils;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

class TextFileUtils
{

	public function new() 
	{
		
	}
	
	public static function updateTextFile(file_path:String, s:String)
	{
		var file_updated:Bool = false;
		var mytextfile:FileOutput = null;
		
		for (i in 0...100)
		{
			if (file_updated) break;
			
			file_updated = true;
			
			try
			{
				mytextfile = File.write(file_path, false);
			}
			catch (unknown : Dynamic)
			{
				file_updated = false;
			}
			
			if (file_updated)
			{
				mytextfile.writeString(s);
				mytextfile.close();
			}
			else
			{
				Sys.sleep(0.1);
			}
		}
		
		if (!file_updated)
		{
			trace("file " + file_path + " is not updated");
		}
	}
	
	public static function replaceString(file_path:String, check_string:String, old_string:String, new_string:String)
	{
		var textfile_data:String = TextFileUtils.readTextFile(file_path);
		
		var r:EReg = new EReg(check_string, "gim");
		
		if (textfile_data != "")
		{
			if (!r.match(textfile_data))
			{
				var r:EReg = new EReg(old_string, "gim");
				
				textfile_data = r.replace(textfile_data, new_string);
				TextFileUtils.updateTextFile(file_path, textfile_data);
			}
		}
		else
		{
			trace("can't find " + file_path + " in output directory");
		}
	}
	
	public static function readTextFile(file_path:String):String
	{
		var textfile_data:String = "";

		if (FileSystem.exists(file_path))
		{			
			var mystatfile:FileInput = File.read(file_path, false);
		
			if (mystatfile != null)
			{
				textfile_data = mystatfile.readAll().toString();
				mystatfile.close();
			}
		}
		
		return textfile_data;
	}
	
}