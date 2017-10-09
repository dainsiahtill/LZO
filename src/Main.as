package
{
	import com.titan.utils.LZO;
	import com.titan.utils.LZO;
	import com.titan.utils.LZOState;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author messiah
	 */
	public class Main extends Sprite 
	{
		
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			var arr:Vector.<uint> = new Vector.<uint>();
			for (var i:int = 0; i < 400; i++) 
			{
				arr[i] = Math.floor(Math.random() * 4);
			}
			var state:LZOState = new LZOState();
			state.inputBuffer = arr;
			
			var lzo:LZO = new LZO();
			lzo.compress(state);
			
			state.inputBuffer = state.outputBuffer;
			state.outputBuffer = null;
			
			lzo.decompress(state);
		}
		
	}
	
}