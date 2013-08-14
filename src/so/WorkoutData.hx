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

package so;

import db.WorkoutData2;
import db.WorkoutInfo;
import flash.net.SharedObject;
import haxe.Serializer;
import haxe.Unserializer;

#if (neko || cpp)
import fileutils.TextFileUtils;
import sys.FileSystem;
#elseif flash
import flash.net.FileReference;
import flash.net.FileFilter;
import flash.events.Event;
import flash.display.Loader;
#end

class WorkoutData
{
	private static var _shared_object:SharedObject;
	private static var _records:Array<WorkoutInfo>;
	
	#if flash
	static private var file_reference:FileReference;
	static private var file_reference2:FileReference;
	#end
	
	public function new() 
	{
		
	}
	
	public static function load():Void
	{
		_shared_object = SharedObject.getLocal("EnduranceLogger");
		_records = new Array();
		
		if (_shared_object.data.records != null)
		{
			var serialized_records:Array<String> = _shared_object.data.records;
			
			for (serialized_record in serialized_records)
			{
				var record:WorkoutInfo = Unserializer.run(serialized_record);
				_records.push(record);
			}
		}
	}
	
	public static function save():Void
	{
		var serialized_records:Array<String> = new Array();
		
		for (record in _records)
		{
			var serialized_record:String = Serializer.run(record);
			serialized_records.push(serialized_record);
		}
		
		_shared_object.data.records = serialized_records;
		_shared_object.flush();
	}
	
	public static function clear():Void
	{
		_records = new Array();
	}
	
	public static function addNewRecord(date:Date, exercise_type:Int = -1, value:Int = 0):Void
	{
		if (exercise_type == -1) exercise_type = GV.exercise_type;
		
		_records.push(new WorkoutInfo(date, exercise_type, value));
	}
	
	public static function addNewRecordNow(value:Int):Void
	{
		addNewRecord(Date.now(), GV.exercise_type, value);
		save();
		
		#if flash
		Main.tracker.customMsg("record added " + GV.exercise_type, "custom", Math.NaN);
		#end
	}
	
	public static function loadSettings():Void
	{
		if (_shared_object.data.settings != null)
		{
			WorkoutData2.parseSettings(_shared_object.data.settings);
		}
	}
	
	public static function saveSettings():Void
	{		
		_shared_object.data.settings = serializeData(GV.sound_on) + "|" + serializeData(GV.social_buttons_on) + "|" + serializeData(GV.check_update_date) + "|" + serializeData(GV.notifications_on);
		_shared_object.flush();
	}
	
	public static function serializeData(data:Dynamic):String
	{
		var serialized_data:String = null;
		
		switch (data)
		{
			case false:
				serialized_data = "0";
			case true:
				serialized_data = "1";
			case _:
				serialized_data = data.toString();
		}
		
		return serialized_data;
	}
	
	static public function getFirstWorkoutDate():Date
	{
		var first_workout_date:Date = null;
		
		if (_records.length > 0) first_workout_date = _records[0].date;
		
		return first_workout_date;
	}
	
	static public function getLastWorkoutDate():Date
	{
		var last_workout_date:Date = null;
		
		if (_records.length > 0) last_workout_date = _records[_records.length-1].date;
		
		return last_workout_date;
	}
	
	static public function getDayWorkoutStats(date1:Date):Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		var day = date1.getDate();
		var month = date1.getMonth();
		var year = date1.getFullYear();
		
		for (record in _records)
		{		
			if (record.exercise_type == GV.exercise_type && record.date.getDate() == day && record.date.getMonth() == month && record.date.getFullYear() == year) 
			{
				array.push(record);
			}
		}
		
		return array;
	}
	
	static public function getMonthStats(date1:Date):Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		var month = date1.getMonth();
		var year = date1.getFullYear();
		
		for (record in _records)
		{		
			if (record.exercise_type == GV.exercise_type && record.date.getMonth() == month && record.date.getFullYear() == year) 
			{
				array.push(record);
			}
		}
		
		return array;
	}
	
	static public function getWeekWorkoutStats(date1:Date):Array<WorkoutInfo>
	{
		var week_start_date:Date = getWeekStartDay(date1);
		
		var array:Array<WorkoutInfo> = new Array();
		
		for (i in 0...7)
		{
			var date:Date = DateTools.delta(week_start_date, DateTools.days(i));
			var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(date);
			
			if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date, 0, getWorkoutInfoSum(workout_info)));
		}
		
		return array;
	}
	
	static private function getMonthStartDate(date1:Date):Date
	{
		return new Date(date1.getFullYear(), date1.getMonth(), 1, 0, 0, 0);
	}
	
	static public function getMonthWorkoutStats(date1:Date):Array<WorkoutInfo>
	{
		var month_start_date:Date = getMonthStartDate(date1);
		
		var array:Array<WorkoutInfo> = new Array();
		
		for (i in 0...DateTools.getMonthDays(date1))
		{
			var date:Date = DateTools.delta(month_start_date, DateTools.days(i));
			var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(date);
			
			if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date, 0, getWorkoutInfoSum(workout_info)));
		}
		
		return array;
	}
	
	static public function getYearWorkoutStats(date1:Date):Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		for (i in 0...12)
		{
			var date2:Date = new Date(date1.getFullYear(), i, 1, 0, 0, 0);
			
			var sum:Int = getWorkoutInfoSum(getMonthStats(date2));
			
			if (sum > 0)
			{
				array.push(new WorkoutInfo(date2, 0, sum));
			}
		}
		
		return array;
	}
	
	static public function getPreviousDaysStats(date1:Date):Array<Array<WorkoutInfo>>
	{		
		var workout_stats_array:Array<Array<WorkoutInfo>> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date == null) return workout_stats_array;
		
		first_workout_date = resetTime(first_workout_date);
		
		var i:Int = 1;
		
		var date2:Date = DateTools.delta(date1, -DateTools.days(i) );
		
		while (date2.getTime() >= first_workout_date.getTime())
		{			
			var array:Array<WorkoutInfo> = new Array();
			
			for ( workout_stats in getDayWorkoutStats(date2))
			{
				array.push(new WorkoutInfo(workout_stats.date, 0, workout_stats.value));
			}
			
			if (array.length > 0)
			{
				workout_stats_array.push(array);
				
				if (workout_stats_array.length >= 15)
				{
					break;
				}
			}
			
			i++;
			
			date2 = DateTools.delta(date1, -DateTools.days(i) );
		}
		
		return workout_stats_array;
	}
	
	static public function getPreviousWeekStats(date1:Date):Array<Array<WorkoutInfo>>
	{
		var workout_stats_array:Array<Array<WorkoutInfo>> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date == null) return workout_stats_array;
		
		first_workout_date = getWeekStartDay(resetTime(getFirstWorkoutDate()));
		
		var week_start_date:Date = getWeekStartDay(date1);
		
		var i:Int = 1;
		
		var date2:Date = DateTools.delta(week_start_date, -DateTools.days(i*7-1) );
		var date3:Date = DateTools.delta(week_start_date, -DateTools.days(i*7) );
		
		while (date2.getTime() >= first_workout_date.getTime())
		{			
			var array:Array<WorkoutInfo> = new Array();
			
			for (i in 0...7)
			{
				var date:Date = DateTools.delta(date2, DateTools.days(i));
				var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(date);
				
				if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date, 0, getWorkoutInfoSum(workout_info)));
			}
						
			if (array.length > 0)
			{
				workout_stats_array.push(array);
				
				if (workout_stats_array.length >= 15)
				{
					break;
				}
			}
			
			i++;
			
			date2 = DateTools.delta(date1, -DateTools.days(i*7-1) );
			date3 = DateTools.delta(date1, -DateTools.days(i*7) );
		}
		
		return workout_stats_array;
	}
	
	static public function getPreviousMonthStats(date1:Date):Array<Array<WorkoutInfo>>
	{
		var workout_stats_array:Array<Array<WorkoutInfo>> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date == null) return workout_stats_array;
		
		first_workout_date = resetTime(first_workout_date);
		
		first_workout_date = new Date(first_workout_date.getFullYear(), first_workout_date.getMonth(), 1, 0, 0, 0);
		
		var month_start_date:Date = getMonthStartDate(date1);
		
		var year:Int = month_start_date.getFullYear();
		var month:Int = month_start_date.getMonth();
		
		month--;
		
		if (month == 0)
		{
			month += 11;
			year--;
		}
		
		var previous_month_date:Date = new Date(year, month, 1, 0, 0, 0);
		
		while (previous_month_date.getTime() >= first_workout_date.getTime())
		{
			var array:Array<WorkoutInfo> = new Array();
		
			for (i in 0...DateTools.getMonthDays(previous_month_date))
			{
				var date:Date = DateTools.delta(previous_month_date, DateTools.days(i));
				var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(date);
				
				if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date, 0, getWorkoutInfoSum(workout_info)));
			}
		
			if (array.length > 0) 
			{
				workout_stats_array.push(array);
				
				if (workout_stats_array.length >= 15)
				{
					break;
				}
			}
			
			month--;
		
			if (month == 0)
			{
				month += 11;
				year--;
			}
			
			previous_month_date = new Date(year, month, 1, 0, 0, 0);
		}
				
		return workout_stats_array;
	}
	
	static public function getPreviousYearStats(date1:Date):Array<Array<WorkoutInfo>>
	{
		var workout_stats_array:Array<Array<WorkoutInfo>> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date == null) return workout_stats_array;
		
		first_workout_date = resetTime(first_workout_date);
		
		var i:Int = 1;
		
		var year_start_date:Date = new Date(date1.getFullYear() - i, 0, 1, 0, 0, 0);
		
		while (year_start_date.getTime() >= first_workout_date.getTime())
		{
			var array:Array<WorkoutInfo> = new Array();
		
			for (i in 0...12)
			{
				var date2:Date = new Date(year_start_date.getFullYear(), i, 1, 0, 0, 0);
				
				var workout_stats_array2 = getMonthStats(date2);
				
				if (workout_stats_array2.length > 0)
				{
					var sum:Int = getWorkoutInfoSum(workout_stats_array2);
					
					array.push(new WorkoutInfo(date2, 0, sum));
				}
			}
			
			if (array.length > 0) 
			{
				workout_stats_array.push(array);
				
				if (workout_stats_array.length >= 15)
				{
					break;
				}
			}
			
			i++;
			
			year_start_date = new Date(date1.getFullYear() - i, 0, 1, 0, 0, 0);
		}
		
		return workout_stats_array;
	}
	
	static public function getAllTimeStats():Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date != null)
		{
			first_workout_date = resetTime(first_workout_date);
			
			var current_date:Date = Date.now();
			
			for (i in first_workout_date.getFullYear()...current_date.getFullYear()+1)
			{
				for (j in 0...12)
				{
					var date2:Date = new Date(i, j, 1, 0, 0, 0);
					
					var workout_stats_array = getMonthStats(date2);
					
					if (workout_stats_array.length > 0)
					{
						var sum:Int = getWorkoutInfoSum(workout_stats_array);
						
						array.push(new WorkoutInfo(date2, 0, sum));
					}
				}
			}
		}
		
		return array;
	}
	
	static public function resetTime(date1:Date):Date
	{
		return DateTools.delta(date1,  -DateTools.hours( date1.getHours() ) -DateTools.minutes(date1.getMinutes()) - DateTools.seconds(date1.getSeconds()));
	}
	
	static public function getWorkoutInfoSum(workout_info:Array<WorkoutInfo>):Int
	{
		var sum:Int = 0;
				
		for (j in 0...workout_info.length)
		{
			sum += workout_info[j].value;
		}
		
		return sum;
	}
	
	static public function checkDayCount():Int
	{
		var day_count:Int = 0;
		
		var first_workout_date:Date = getFirstWorkoutDate();
		var last_workout_date:Date = getLastWorkoutDate();
		
		if (first_workout_date != null && last_workout_date != null)
		{		
			first_workout_date = resetTime(first_workout_date);
			last_workout_date = resetTime(last_workout_date);
			last_workout_date = DateTools.delta(last_workout_date, DateTools.days(1));
			
			var i:Int = 0;
			
			var workout_date:Date =  DateTools.delta(last_workout_date, -DateTools.days(i));
			
			while (workout_date.getTime() >= first_workout_date.getTime())
			{							
				var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(workout_date);
				
				var sum:Int = getWorkoutInfoSum(workout_info);
				
				if (sum > 0 && workout_info.length > 0)
				{
					day_count++;
				}
				
				i++;
				
				workout_date = DateTools.delta(last_workout_date, -DateTools.days(i));
			}
		}
		
		return day_count;
	}
	
	static public function checkMonthCount():Int
	{
		var month_count:Int = 0;
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date != null)
		{
			var current_date:Date = Date.now();
			
			for (i in first_workout_date.getFullYear()...current_date.getFullYear()+1)
			{
				for (j in 0...12)
				{
					var date2:Date = new Date(i, j, 1, 0, 0, 0);
					
					var workout_stats_array = getMonthStats(date2);
					if (workout_stats_array.length > 0) month_count++;
				}
			}
		}
		
		return month_count;
	}
	
	static public function getWeekDay(date1:Date):Float
	{
		var n:Float = date1.getDay() - 1;
		
		if (n == -1) 
		{
			n = 6;
		}
		
		return n;
	}
	
	static public function getWeekStartDay(date1:Date):Date
	{		
		return DateTools.delta(date1, -DateTools.days(getWeekDay(date1)));
	}
	
	static public function getAllRecords():Array<WorkoutInfo>
	{
		return _records;
	}
	
	static public function getDayRecord()
	{
		var record:Int = -1;
		var date:Date = null;
		
		var first_workout_date:Date = getFirstWorkoutDate();
		var last_workout_date:Date = getLastWorkoutDate();
		
		if (first_workout_date != null && last_workout_date != null)
		{		
			first_workout_date = resetTime(first_workout_date);
			last_workout_date = resetTime(last_workout_date);
			last_workout_date = DateTools.delta(last_workout_date, DateTools.days(1));
			
			var i:Int = 0;
			
			var workout_date:Date =  DateTools.delta(last_workout_date, -DateTools.days(i));
			
			while (workout_date.getTime() >= first_workout_date.getTime())
			{							
				var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(workout_date);
				
				var sum:Int = getWorkoutInfoSum(workout_info);
				
				if (sum > record && workout_info.length > 0)
				{
					record = sum;
					date = workout_info[0].date;
				}
				
				i++;
				
				workout_date = DateTools.delta(last_workout_date, -DateTools.days(i));
			}
		}
		
		return {date:date, record:record};
	}
	
	static public function getMonthRecord()
	{
		var record:Int = -1;
		var date:Date = null;
		
		var first_workout_date:Date = getFirstWorkoutDate();
		var last_workout_date:Date = getLastWorkoutDate();
		
		if (first_workout_date != null && last_workout_date != null)
		{			
			for (i in first_workout_date.getFullYear()...last_workout_date.getFullYear()+1)
			{
				for (j in 0...12)
				{
					var date2:Date = new Date(i, j, 1, 0, 0, 0);
					
					var workout_stats_array = getMonthStats(date2);
					
					if (workout_stats_array.length > 0)
					{
						var sum:Int = getWorkoutInfoSum(workout_stats_array);
						
						if (sum > record)
						{
							record = sum;
							date = date2;
						}
					}
				}
			}
		}
		
		return { date:date, record:record };
	}
	
	static public function exportWorkoutStats() 
	{
		#if (neko || cpp)
			TextFileUtils.updateTextFile(Utils.getExecutablePath() + "workout.txt", Serializer.run(_shared_object.data.records));
			GV.showText("Database was succefully exported to workout.txt");
		#elseif flash
			file_reference = new FileReference();
			file_reference.save(Serializer.run(_shared_object.data.records), "workout.txt");
			file_reference.addEventListener(Event.COMPLETE, onSaveComplete);
		#end
	}
	
	#if flash
	static private function onSaveComplete(e:Event):Void 
	{
		GV.showText(Localization.get("$DATABASEEXPORTSUCCESS"));
		file_reference.removeEventListener(Event.COMPLETE, onSaveComplete);
		file_reference = null;
	}
	#end
	
	static public function importWorkoutStats()
	{
		#if flash
		file_reference2 = new FileReference();
		file_reference2.browse([new FileFilter("Workout database(workout.txt)", "workout.txt")]);
		file_reference2.addEventListener(Event.SELECT, onFileSelected);
		#elseif windows
			var workout_db_path:String = Utils.getExecutablePath() + "workout.txt";
			
			if (FileSystem.exists(workout_db_path))
			{
				_shared_object.data.records = Unserializer.run(TextFileUtils.readTextFile(workout_db_path));
				_shared_object.flush();
		
				load();
				GV.updateData();
			}
			else
			{
				GV.showText(Localization.get("$CANNOTFINDDATABASE"));
			}
		#end
	}
	
	static public function getLanguage():String
	{
		return _shared_object.data.locale;
	}
	
	static public function loadLanguage():Bool
	{
		var loaded:Bool = false;
		
		if (_shared_object.data.locale != null)
		{
			loaded = true;
		}
		
		return loaded;
	}
	
	static public function saveLanguage(locale:String):Void
	{
		_shared_object.data.locale = locale;
		_shared_object.flush();
	}
	
	static public function resetLanguage():Void
	{
		_shared_object.data.locale = null;
		_shared_object.flush();
	}
	
	#if flash
	static private function onFileSelected(e:Event):Void 
	{
		file_reference2.removeEventListener(Event.SELECT, onFileSelected);
		file_reference2.addEventListener(Event.COMPLETE, onLoadComplete);
		file_reference2.load();
	}
	
	static private function onLoadComplete(e:Event):Void 
	{
		_shared_object.data.records = Unserializer.run(e.target.data);
		_shared_object.flush();
		
		load();
		GV.updateData();
	}
	#end
}