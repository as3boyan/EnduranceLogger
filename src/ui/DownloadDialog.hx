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
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import motion.Actuate;

class DownloadDialog extends Sprite
{
	var tf:TextField;

	public function new() 
	{
		super();
		
		var background:ColoredRect = new ColoredRect(400, 300, 13493987);
		addChild(background);
		
		var text_format2:TextFormat = new TextFormat("Arial", 16);
		text_format2.align = TextFormatAlign.CENTER;
		
		var tf_title:TextField = new TextField();
		tf_title.defaultTextFormat = text_format2;
		tf_title.text = "New version available!";
		tf_title.width = width;
		tf_title.height = 30;
		tf_title.y = 10;
		addChild(tf_title);
		
		var start_download_button:Button = new Button(this, width/2 - 75, 275, "Start download", onStartDownloadClick);
		start_download_button.setWidth(null, null, 3984056);
		addChild(start_download_button);
		
		var cancel_button:Button = new Button(this, width/2 + 75, 275, "Cancel", onCancelClick);
		cancel_button.setWidth(null, null, 16777106);
		addChild(cancel_button);
		
		var text_format:TextFormat = new TextFormat("Arial", 16);
		
		tf = new TextField();
		tf.defaultTextFormat = text_format;
		tf.multiline = true;
		tf.wordWrap = true;
		tf.selectable = false;
		tf.width = width - 20;
		tf.x = 10;
		tf.y = 35;
		tf.height = 195;
		tf.background = true;
		tf.backgroundColor = 0xFFFFFF;
		tf.border = true;
		tf.borderColor = 0xDADADA;
		addChild(tf);
		
		alpha = 0;
		visible = false;
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	function onStartDownloadClick() 
	{
		GV.startDownload();
		Actuate.tween(this, 1, { alpha:0 } ).onComplete(hide);
	}
	
	function onCancelClick() 
	{
		Actuate.tween(this, 1, { alpha:0 } ).onComplete(hide);
	}
	
	public function show()
	{
		Actuate.tween(this, 1, { alpha:1 } );
		visible = true;
	}
	
	function hide() 
	{
		visible = false;
	}
	
	private function onAdded(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		x = (stage.stageWidth - width) / 2;
		y = (stage.stageHeight - height) / 2;
	}
	
	public function setCommitLog(_text:String)
	{
		tf.text = _text;
	}	
}