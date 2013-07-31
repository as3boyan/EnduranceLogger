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

import sys.db.Sqlite;
import sys.db.TableCreate;

class WorkoutData 
{
	static private var cnx;
	static private var week_days:Array<String>;
	static private var month_text:Array<String>;
	
	static public function init() 
	{
		var executable_path:String = Sys.executablePath();
		executable_path = executable_path.substring(0, executable_path.lastIndexOf("\\")) + "\\";

		cnx = Sqlite.open(executable_path + "workout.db");
		sys.db.Manager.cnx = cnx;
		sys.db.Manager.initialize();
		
		if ( !TableCreate.exists(WorkoutStats.manager) )
		{
			TableCreate.create(WorkoutStats.manager);
		}
		
		week_days = new Array();
		week_days.push("Monday");
		week_days.push("Tuesday");
		week_days.push("Wednesday");
		week_days.push("Thursday");
		week_days.push("Friday");
		week_days.push("Saturday");
		week_days.push("Sunday");
		
		month_text = new Array();
		month_text.push("January");
		month_text.push("February");
		month_text.push("March");
		month_text.push("April");
		month_text.push("May");
		month_text.push("June");
		month_text.push("July");
		month_text.push("August");
		month_text.push("September");
		month_text.push("October");
		month_text.push("November");
		month_text.push("December");	
	}
	
	static public function close()
	{
		sys.db.Manager.cleanup();
		cnx.close();
	}
	
	static public function getMonthWorkoutStats(date1:Date):Array<WorkoutInfo>
	{
		var month_start_date:Date = getMonthStartDate(date1);
		
		var array:Array<WorkoutInfo> = new Array();
		
		for (i in 0...DateTools.getMonthDays(date1))
		{
			var date:Date = DateTools.delta(month_start_date, DateTools.days(i));
			var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(date);
			
			if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date, getWorkoutInfoSum(workout_info)));
		}
		
		return array;
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
	
	static public function getWeekWorkoutStats(date1:Date):Array<WorkoutInfo>
	{
		var week_start_date:Date = getWeekStartDay(date1);
		
		var array:Array<WorkoutInfo> = new Array();
		
		for (i in 0...7)
		{
			var date:Date = DateTools.delta(week_start_date, DateTools.days(i));
			var workout_info:Array<WorkoutInfo> = getDayWorkoutStats(date);
			
			if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date,getWorkoutInfoSum(workout_info)));
		}
		
		return array;
	}
	
	static public function getPreviousDaysStats(date1:Date):Array<Array<WorkoutInfo>>
	{		
		var workout_stats_array:Array<Array<WorkoutInfo>> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date == null) return workout_stats_array;
		
		var i:Int = 1;
		
		var date2:Date = DateTools.delta(date1, -DateTools.days(i-1) );
		var date3:Date = DateTools.delta(date1, -DateTools.days(i) );
		
		while (date2.getTime() >= first_workout_date.getTime())
		{			
			var array:Array<WorkoutInfo> = new Array();
			
			for ( workout_stats in WorkoutStats.manager.search($date >= date3 && $date < date2 && $exercise_type == GV.exercise_type))
			{
				array.push(new WorkoutInfo(workout_stats.date.toString(),workout_stats.value));
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
			
			date2 = DateTools.delta(date1, -DateTools.days(i-1) );
			date3 = DateTools.delta(date1, -DateTools.days(i) );
		}
		
		return workout_stats_array;
	}
	
	static public function getPreviousWeekStats(date1:Date):Array<Array<WorkoutInfo>>
	{
		var workout_stats_array:Array<Array<WorkoutInfo>> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date == null) return workout_stats_array;
		
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
				
				if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date,getWorkoutInfoSum(workout_info)));
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
				
				if (workout_info.length > 0) array.push(new WorkoutInfo(workout_info[0].date, getWorkoutInfoSum(workout_info)));
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
		
		var i:Int = 1;
		
		var year_start_date:Date = new Date(date1.getFullYear() - i, 0, 1, 0, 0, 0);
		
		while (year_start_date.getTime() >= first_workout_date.getTime())
		{
			var array:Array<WorkoutInfo> = new Array();
		
			for (i in 0...12)
			{
				var date2:Date = new Date(year_start_date.getFullYear(), i, 1, 0, 0, 0);
				var date3:Date = DateTools.delta(date2, DateTools.days(DateTools.getMonthDays(date2)));
				
				var workout_stats_array2:List<WorkoutStats> = WorkoutStats.manager.search($date >= date2 && $date < date3 && $exercise_type == GV.exercise_type);
				
				if (workout_stats_array2.length > 0)
				{
					var sum:Int = 0;
				
					for ( workout_stats in workout_stats_array2)
					{
						sum += workout_stats.value;
					}
					
					var date_string:String = DateTools.format(date2, "%Y-%m");
					array.push(new WorkoutInfo(date_string, sum));
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
	
	static private function getMonthStartDate(date1:Date):Date
	{
		return new Date(date1.getFullYear(), date1.getMonth(), 1, 0, 0, 0);
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
	
	static public function getFirstWorkoutDate():Date
	{
		var first_workout_date:Date = null;
		
		var workout_stats:WorkoutStats = WorkoutStats.manager.select($id == 1);
		
		if (workout_stats != null)
		{
			first_workout_date = Date.fromString(workout_stats.date.toString());
		}
		
		return first_workout_date;
	}
	
	static public function getDayWorkoutStats(date1:Date, ?n:Int = 1):Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		var date2:Date = DateTools.delta(date1, DateTools.days(n) );
				
		for ( workout_stats in WorkoutStats.manager.search($date >= date1 && $date < date2 && $exercise_type == GV.exercise_type))
		{
			var date:Date = Date.fromString(workout_stats.date.toString());
			var date_string:String = null;	
			
			switch (GV.time_range)
			{
				case 1: 
					date_string = date.toString();
					date_string = date_string.substr(date_string.indexOf(" ") + 1);
				case 2:
					date_string = week_days[Std.int(getWeekDay(date))];
				case 3: 
					date_string = month_text[date.getMonth()] + " " + Std.string(date.getDate());
				case _:
					date_string = date.toString();
				
			}
			
			array.push(new WorkoutInfo(date_string,workout_stats.value));
		}	
		
		return array;
	}
	
	static public function addWorkoutStatsNow(_value:Int)
	{
		var workout_stats:WorkoutStats = new WorkoutStats();
		workout_stats.date = Date.now();
		workout_stats.exercise_type = GV.exercise_type;
		workout_stats.value = _value;
		workout_stats.insert();
	}
	
	static public function addWorkoutStats(_date:Date, _value:Int)
	{
		var workout_stats:WorkoutStats = new WorkoutStats();
		workout_stats.date = _date;
		workout_stats.exercise_type = GV.exercise_type;
		workout_stats.value = _value;
		workout_stats.insert();
	}
	
	static public function getSumBetweenDate(date2:Date, date3:Date):Int
	{
		var workout_stats_array:List<WorkoutStats> = WorkoutStats.manager.search($date >= date2 && $date < date3 && $exercise_type == GV.exercise_type);
		
		var sum:Int = 0;
		
		if (workout_stats_array.length > 0)
		{
			for ( workout_stats in workout_stats_array)
			{
				sum += workout_stats.value;
			}
		}
		
		return sum;
	}
	
	static public function getYearWorkoutStats(date1:Date):Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		for (i in 0...12)
		{
			var date2:Date = new Date(date1.getFullYear(), i, 1, 0, 0, 0);
			var date3:Date = DateTools.delta(date2, DateTools.days(DateTools.getMonthDays(date2)));
			
			var sum:Int = getSumBetweenDate(date2, date3);
			
			if (sum > 0)
			{
				var date_string:String = DateTools.format(date2, "%Y-%m");
				array.push(new WorkoutInfo(date_string, sum));
			}
		}
		
		return array;
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
					var date3:Date = DateTools.delta(date2, DateTools.days(DateTools.getMonthDays(date2)));
					
					var workout_stats_array:List<WorkoutStats> = WorkoutStats.manager.search($date >= date2 && $date < date3 && $exercise_type == GV.exercise_type);
					if (workout_stats_array.length > 0) month_count++;
				}
			}
		}
		
		return month_count;
	}
	
	static public function getAllTimeStats():Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		var first_workout_date:Date = getFirstWorkoutDate();
		
		if (first_workout_date != null)
		{
			var current_date:Date = Date.now();
			
			for (i in first_workout_date.getFullYear()...current_date.getFullYear()+1)
			{
				for (j in 0...12)
				{
					var date2:Date = new Date(i, j, 1, 0, 0, 0);
					var date3:Date = DateTools.delta(date2, DateTools.days(DateTools.getMonthDays(date2)));
					
					var workout_stats_array:List<WorkoutStats> = WorkoutStats.manager.search($date >= date2 && $date < date3 && $exercise_type == GV.exercise_type);
					
					if (workout_stats_array.length > 0)
					{
						var sum:Int = 0;
					
						for ( workout_stats in workout_stats_array)
						{
							sum += workout_stats.value;
						}
						
						var date_string:String = DateTools.format(date2, "%Y-%m");
						array.push(new WorkoutInfo(date_string, sum));
					}
				}
			}
		}
		
		return array;
	}
	
	static public function getAllRecords():Array<WorkoutInfo>
	{
		var array:Array<WorkoutInfo> = new Array();
		
		for (workout_stats in WorkoutStats.manager.search(true))
		{
			array.push(new WorkoutInfo(workout_stats.date.toString(),workout_stats.value));
		}
		
		return array;
	}
	
	static public function getLastWorkoutDate():Date
	{
		var last_workout_date:Date = null;
		
		for (workout_stats in WorkoutStats.manager.search(true, { limit:1, orderBy: -id } ))
		{
			last_workout_date = Date.fromString(workout_stats.date.toString());
		}
		
		return last_workout_date;
	}
	
	static public function resetTime(date1:Date)
	{
		return DateTools.delta(date1,  -DateTools.hours( date1.getHours() ) -DateTools.minutes(date1.getMinutes()) - DateTools.seconds(date1.getSeconds()));
	}
	
	static public function getDayRecord()
	{
		var record:Int = -1;
		var date:String = "";
		
		var first_workout_date:Date = getFirstWorkoutDate();
		var last_workout_date:Date = getLastWorkoutDate();
		
		if (first_workout_date != null && last_workout_date != null)
		{		
			first_workout_date = resetTime(first_workout_date);
			last_workout_date = resetTime(last_workout_date);
			
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
		var date:String = "";
		
		var first_workout_date:Date = getFirstWorkoutDate();
		var last_workout_date:Date = getLastWorkoutDate();
		
		if (first_workout_date != null && last_workout_date != null)
		{			
			for (i in first_workout_date.getFullYear()...last_workout_date.getFullYear()+1)
			{
				for (j in 0...12)
				{
					var date2:Date = new Date(i, j, 1, 0, 0, 0);
					var date3:Date = DateTools.delta(date2, DateTools.days(DateTools.getMonthDays(date2)));
					
					var workout_stats_array:List<WorkoutStats> = WorkoutStats.manager.search($date >= date2 && $date < date3 && $exercise_type == GV.exercise_type);
					
					if (workout_stats_array.length > 0)
					{
						var sum:Int = 0;
					
						for ( workout_stats in workout_stats_array)
						{
							sum += workout_stats.value;
						}
						
						if (sum > record)
						{
							record = sum;
							date = date2.toString();
						}
					}
				}
			}
		}
		
		return { date:date, record:record };
	}
}