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
import motion.Actuate;

class ColoredPointsManager
{
	
	var colored_points:Array<ColoredPoint>;
	public var k:Int;

	public function new(n:Int) 
	{
		colored_points = new Array<ColoredPoint>();
		
		for (i in 0...n)
		{
			colored_points.push(new ColoredPoint());
		}
		
		k = 0;
	}
	
	public function getNext():ColoredPoint
	{
		var colored_point:ColoredPoint = null;
		
		if (k < colored_points.length - 1)
		{
			colored_point = colored_points[k];
			Actuate.stop(colored_point);
		}
		else
		{
			colored_point = new ColoredPoint();
			colored_points.push(colored_point);
		}
		
		k++;
		
		return colored_point;
	}
	
	public function hideUnusedPoints():Void
	{
		var colored_point:ColoredPoint;
		
		for (i in k...colored_points.length)
		{
			if (colored_points[i].parent != null)
			{
				colored_point = colored_points[i];
				colored_point.parent.removeChild(colored_point);
				Actuate.stop(colored_point);
			}
		}
	}
	
}