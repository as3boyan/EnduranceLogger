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

package db;

#if (neko || cpp)
import fileutils.TextFileUtils;
import sys.FileSystem;
#end

#if neko
import sys.db.Sqlite;
import sys.db.TableCreate;
#end

class WorkoutData2
{

	public function new() 
	{
		
	}
	
	#if neko
	
	public static function searchDatabase():Void
	{
		var db_path:String = Utils.getExecutablePath() + "workout.db";
		
		if (FileSystem.exists(db_path))
		{
			so.WorkoutData.clear();
			
			var cnx = Sqlite.open(db_path);
			sys.db.Manager.cnx = cnx;
			sys.db.Manager.initialize();
			
			if (TableCreate.exists(WorkoutStats.manager) )
			{
				for (workout_stats in WorkoutStats.manager.search(true))
				{
					so.WorkoutData.addNewRecord(Date.fromString(workout_stats.date.toString()), workout_stats.exercise_type, workout_stats.value);
				}
			}
			
			sys.db.Manager.cleanup();
			cnx.close();
			
			so.WorkoutData.save();
			FileSystem.deleteFile(db_path);
		}		
	}
	
	#end
	
	#if (windows && cpp)
	
	public static function searchDatabase():Void
	{
		var db_path:String = Utils.getExecutablePath() + "workout.db";
		
		if (FileSystem.exists(db_path))
		{
			so.WorkoutData.clear();
			
			var cnx:cpp.db.Connection = cpp.db.Sqlite.open(db_path);
			var workout_stats_array = cnx.request("SELECT * FROM WorkoutStats");
			
			for (workout_stats in workout_stats_array)
			{
				so.WorkoutData.addNewRecord(Date.fromString(workout_stats.date.toString()), workout_stats.exercise_type, workout_stats.value);
			}
			
			cnx.close();
			
			so.WorkoutData.save();
			FileSystem.deleteFile(db_path);
		}		
	}
	
	#end
	
	#if (neko || windows)
	
	public static function searchSettings():Void
	{
		var settings_path:String = Utils.getExecutablePath() + "settings.cfg";
		
		if (FileSystem.exists(settings_path))
		{
			var settings_string:String = TextFileUtils.readTextFile(settings_path);
			parseSettings(settings_string);
			so.WorkoutData.saveSettings();
			FileSystem.deleteFile(settings_path);
		}
	}
			
	#end
	
	public static function getArrayElement(array:Array<String>, i:Int):Dynamic
	{
		var array_element = null;
		
		if (array.length > i)
		{
			array_element = array[i];
		}
		
		return array_element;
	}
	
	public static function unserializeData(data:String):Dynamic
	{
		var unserialized_data:Dynamic = null;
		
		switch (data)
		{
			case "0":
				unserialized_data = false;
			case "1":
				unserialized_data = true;
			case _:
				unserialized_data = Date.fromString(data);
		}
		
		return unserialized_data;
	}
	
	public static function parseSettings(settings_string:String):Void
	{
		var settings_array:Array<String> = settings_string.split("|");
		
		GV.sound_on = unserializeData(getArrayElement(settings_array, 0));
		GV.social_buttons_on = unserializeData(getArrayElement(settings_array, 1));
		GV.check_update_date = unserializeData(getArrayElement(settings_array, 2));
		GV.notifications_on = unserializeData(getArrayElement(settings_array, 3));
	}
}