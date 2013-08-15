package ;
import flash.events.Event;

class CustomPreloader extends NMEPreloader
{	
	public function new() 
	{
		super();
		addEventListener(Event.RESIZE, onResize);
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}
	
	private function onAdded(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		onResize(null);
	}
	
	private function onResize(e:Event):Void 
	{
		scaleX = stage.stageWidth / 800;
		scaleY = stage.stageHeight / 480;
	}
	
}