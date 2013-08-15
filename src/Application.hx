package ;

import flash.display.MovieClip;

class Application extends MovieClip
{
	public var _mochiads_game_id:String = "980033a1a55a7728";

	public function new() 
	{
		super();
		
		addChild(new Main());
	}
	
}