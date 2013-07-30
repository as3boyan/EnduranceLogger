/*
 * Endurance Logger, program that is intended to help your to track your fitness progress
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

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.text.TextFieldType;
import haxe.Timer;
import motion.Actuate;
import motion.easing.Elastic;
import motion.easing.Quad;
import openfl.Assets;

class InputField extends Sprite
{
	var tf:TextField;
	var input_tf:TextField;
	var exercise_type:Int;

	public function new() 
	{
		super();
		
		var background:ColoredRect = new ColoredRect(250,150,13493987);
		addChild(background);
		
		var text_format2:TextFormat = new TextFormat("Arial");
		text_format2.align = TextFormatAlign.CENTER;
		text_format2.size = 16;
		
		tf = new TextField();
		tf.width = width;
		tf.height = 30;
		tf.defaultTextFormat = text_format2;
		tf.y = 10;
		addChild(tf);
		
		var text_format:TextFormat = new TextFormat("Arial");
		text_format.align = TextFormatAlign.LEFT;
		text_format.size = 24;
		
		input_tf = new TextField();
		input_tf.type = TextFieldType.INPUT;
		input_tf.width = 100;
		input_tf.height = 30;
		input_tf.x = (width - input_tf.width) / 2;
		input_tf.y = 43;
		input_tf.defaultTextFormat = text_format;
		input_tf.text = "0";
		input_tf.border = true;
		input_tf.borderColor = 0xDADADA;
		input_tf.background = true;
		input_tf.backgroundColor = 0xFFFFFF;
		addChild(input_tf);
		
		var ok_button:Button = new Button(this, width / 2, 120, "OK", onClick);
		ok_button.setWidth(null, null, 3984056);
		addChild(ok_button);
		
		visible = false;
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		alpha = 0;
	}
	
	public function onClick() 
	{
		var n = Std.parseInt(input_tf.text);
		
		if (n != null && n>0)
		{			
			var prev_exercise_type:Int = GV.exercise_type;
			GV.exercise_type = exercise_type;
			WorkoutData.addWorkoutStatsNow(n);
			
			var prev_time_range:Int = GV.time_range;
			GV.time_range = 4;
			
			var day_record = WorkoutData.getDayRecord();
			var current_date:Date = WorkoutData.resetTime(Date.now());
			
			if (WorkoutData.resetTime(Date.fromString(day_record.date)) != current_date)
			{
				var workout_info = WorkoutData.getDayWorkoutStats(current_date);
				var sum:Int = WorkoutData.getWorkoutInfoSum(workout_info);
				var diff:Int = day_record.record - sum;
				
				if (diff > 0)
				{
					GV.showText("Do " + Std.string(diff) + " additional " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + " to break day record(" + Std.string(day_record.record) + " on " +  Std.string(day_record.date) + ")", 10000 );
				}
			}
			else
			{
				GV.showText("Congratulations! You have set new daily record for " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + "(" + Std.string(day_record.record)  + ")", 5000);
				
				var timer:Timer = new Timer(1500);
				timer.run = function ():Void
				{
					Assets.getSound("sounds/newdailyrecord.mp3").play();
				}
			}
			
			var month_record = WorkoutData.getMonthRecord();
			var month_date:Date = Date.fromString(month_record.date);
			
			if (month_date.getMonth() != current_date.getMonth() && month_date.getFullYear() != current_date.getFullYear())
			{
				var date2:Date = new Date(current_date.getFullYear(), current_date.getMonth(), 1, 0, 0, 0);
				var date3:Date = DateTools.delta(date2, DateTools.days(DateTools.getMonthDays(date2)));
				
				var sum:Int = WorkoutData.getSumBetweenDate(date2, date3);
				var diff:Int = month_record.record - sum;
				
				if (diff > 0)
				{
					GV.showText("Do" + Std.string(diff) + " additional " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + " to break month record(" + Std.string(month_record.record) + " on " +  DateTools.format(cast(month_record.date, Date), "%Y-%m") + ")", 10000);
				}
			}
			else
			{
				GV.showText("Congratulations! You have set new month record for " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + "(" + Std.string(month_record.record)  + ")", 5000);
				
				var timer:Timer = new Timer(3000);
				timer.run = function ():Void
				{
					Assets.getSound("sounds/newmonthrecord.mp3").play();
				}
			}
			
			GV.time_range = prev_time_range;
			GV.exercise_type = prev_exercise_type;
			
			var k:Int = Utils.randInt(1, 4);
			var sound_type:String = "sounds/";
			
			switch (k)
			{
				case 1: sound_type += "awesome" + Std.string(Utils.randInt(1,3)) + ".mp3";
				case 2: sound_type += "excellent" + Std.string(Utils.randInt(1,4)) + ".mp3";
				case 3: sound_type += "goodjob" + Std.string(Utils.randInt(1,1)) + ".mp3";
				case 4: sound_type += "welldone" + Std.string(Utils.randInt(1,3)) + ".mp3";
			}
			
			if (GV.exercise_type == exercise_type) GV.updateData();
			
			Assets.getSound(sound_type).play();
		}
		else
		{
			input_tf.text = "0";
		}
		
		hide();
	}
	
	private function onAdded(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		x = (stage.stageWidth - width) / 2;
		y = (stage.stageHeight - height) / 2;
	}
	
	public function show():Void
	{		
		if (visible == false || mouseEnabled == false)
		{
			Actuate.stop(this);
		
			x = -150;
			Actuate.tween(this, 3, { x:(stage.stageWidth - width) / 2, alpha:1 } );
		}
		
		var exercise_type_text:String = null;
		
		switch (GV.exercise_type)
		{
			case 1: exercise_type_text = "pushups";
			case 2: exercise_type_text = "pullups";
			case 3: exercise_type_text = "squats";
			case 4: exercise_type_text = "situps";
			case 5: exercise_type_text = "dips";
			case _: trace(GV.exercise_type);
		}
		
		tf.text = "How much " + exercise_type_text + " did you made?";
		visible = true;
		mouseEnabled = true;
		mouseChildren = true;
		
		exercise_type = GV.exercise_type;
	}
	
	public function hide():Void
	{
		Actuate.stop(this);
		
		mouseEnabled = false;
		mouseChildren = false;
		
		Actuate.tween(this, 3, { alpha:0,x:stage.stageWidth } ).onComplete(setVisibleToFalse);
	}
	
	function setVisibleToFalse():Void
	{
		visible = false;
	}
	
}