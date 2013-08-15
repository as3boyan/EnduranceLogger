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
import so.WorkoutData;

class InputField extends Sprite
{
	var tf:TextField;
	var input_tf:TextField;
	var exercise_type:Int;
	var container:Sprite;

	public function new() 
	{
		super();
		
		container = new Sprite();
		addChild(container);
		
		var background:ColoredRect = new ColoredRect(280, 150, 13493987);
		background.x = - background.width / 2;
		background.y = - background.height / 2;
		container.addChild(background);
		
		var text_format2:TextFormat = new TextFormat("Arial");
		text_format2.align = TextFormatAlign.CENTER;
		text_format2.size = 16;
		
		tf = new TextField();
		tf.width = width;
		tf.height = 30;
		tf.defaultTextFormat = text_format2;
		tf.x = - background.width / 2;
		tf.y = 10 - background.height / 2;
		container.addChild(tf);
		
		var text_format:TextFormat = new TextFormat("Arial");
		text_format.align = TextFormatAlign.LEFT;
		text_format.size = 24;
		
		input_tf = new TextField();
		input_tf.type = TextFieldType.INPUT;
		input_tf.width = 100;
		input_tf.height = 30;
		input_tf.x = (width - input_tf.width) / 2- background.width / 2;
		input_tf.y = 43 - background.height / 2;
		input_tf.defaultTextFormat = text_format;
		input_tf.text = "0";
		input_tf.border = true;
		input_tf.borderColor = 0xDADADA;
		input_tf.background = true;
		input_tf.backgroundColor = 0xFFFFFF;
		container.addChild(input_tf);
		
		var ok_button:Button = new Button(this, width / 2 - background.width/2, 120 - background.height/2, Localization.get("$OK"), onClick);
		ok_button.setWidth(null, null, 3984056);
		container.addChild(ok_button);
		
		visible = false;
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	public function onClick() 
	{		
		var n = Std.parseInt(input_tf.text);
		
		if (n != null && n>0)
		{			
			var prev_exercise_type:Int = GV.exercise_type;
			GV.exercise_type = exercise_type;
			so.WorkoutData.addNewRecordNow(n);
			
			var prev_time_range:Int = GV.time_range;
			GV.time_range = 4;
			
			var current_date:Date = so.WorkoutData.resetTime(Date.now());
			
			if (WorkoutData.checkDayCount() > 1)
			{
				var day_record = so.WorkoutData.getDayRecord();
				
				if (day_record.date.getDate() != current_date.getDate() || day_record.date.getMonth() != current_date.getMonth() || day_record.date.getFullYear() != current_date.getFullYear())
				{
					var workout_info = so.WorkoutData.getDayWorkoutStats(current_date);
					var sum:Int = so.WorkoutData.getWorkoutInfoSum(workout_info);
					var diff:Int = day_record.record - sum;
					
					if (diff > 0)
					{
						var date_string:String = Std.string(day_record.date);
						date_string = date_string.substr(0, date_string.indexOf(" "));
						
						GV.showText(Localization.getAndReplace("$DOADDITIONAL", Std.string(diff)) +  " " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + " " + Localization.getAndReplace("$TOBREAKDAYRECORDON", Std.string(day_record.record)) + " " +  date_string + ")", 10000 );
					}
				}
				else
				{				
					GV.showText(Localization.get("$NEWDAILYRECORD") + " " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + "(" + Std.string(day_record.record)  + ")", 5000);
					
					if (GV.sound_on)
					{
						var timer:Timer = new Timer(1500);
						timer.run = function ():Void
						{
							Assets.getSound("sounds/newdailyrecord.mp3").play();
							timer.stop();
						}
					}
				}
			}
			
			if (so.WorkoutData.checkMonthCount() > 1)
			{
				var month_record = so.WorkoutData.getMonthRecord();
				var month_date:Date = month_record.date;
				
				if (month_date.getMonth() != current_date.getMonth() || month_date.getFullYear() != current_date.getFullYear())
				{
					var date2:Date = new Date(current_date.getFullYear(), current_date.getMonth(), 1, 0, 0, 0);
					
					var sum:Int = so.WorkoutData.getWorkoutInfoSum(so.WorkoutData.getMonthStats(date2));
					var diff:Int = month_record.record - sum;
					
					if (diff > 0)
					{
						GV.showText(Localization.getAndReplace("$DOADDITIONAL", Std.string(diff)) +  " " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + " " + Localization.getAndReplace("$TOBREAKMONTHRECORDON", Std.string(month_record.record)) + " " +  DateTools.format(cast(month_record.date, Date), "%Y-%m") + ")", 10000);
					}
				}
				else
				{
					GV.showText(Localization.get("$NEWMONTHRECORD") + " " + GV.exercise_text[GV.exercise_type-1].toLowerCase() + "(" + Std.string(month_record.record)  + ")", 5000);
					
					if (GV.sound_on)
					{
						var timer:Timer = new Timer(3000);
						timer.run = function ():Void
						{
							Assets.getSound("sounds/newmonthrecord.mp3").play();
							timer.stop();
						}
					}
					
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
			
			if (GV.sound_on) Assets.getSound(sound_type).play();
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
		
		x = (800) / 2;
		y = (480) / 2;
		
		container.alpha = 0;
		container.scaleX = 0.1;
		container.scaleX = 0.1;
	}
	
	public function show():Void
	{	
		if (visible == false || mouseEnabled == false)
		{
			Actuate.stop(this);
		
			//x = -150;
			Actuate.tween(container, 0.4, {alpha:1, scaleX:1, scaleY:1 } );
		}
		
		parent.setChildIndex(this, parent.numChildren - 1);
		
		var exercise_type_text:String = null;
		
		exercise_type_text = GV.exercise_text[GV.exercise_type-1].toLowerCase();
		
		tf.text = Localization.getAndReplace("$HOWMUCH", exercise_type_text);
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
		
		Actuate.tween(container, 0.4, { alpha:0, scaleX:0.1, scaleY:0.1 } ).autoVisible(true);
		
		stage.focus = null;
	}
	
}