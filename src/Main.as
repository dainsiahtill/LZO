package
{
	import com.titan.utils.HexUtil;
	import com.titan.utils.LZO;
	import com.titan.utils.LZO;
	import com.titan.utils.LZOState;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
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
			
			var bytes:ByteArray = new ByteArray();
			for (var i:int = 0; i < 400; i++) 
			{
				bytes.writeByte(Math.floor(Math.random() * 4));
			}
			
			var lzo:LZO = new LZO();
			var compressedBytes:ByteArray = lzo.compress(bytes);
			trace("length:" + compressedBytes.length);
			
			bytes = lzo.decompress(compressedBytes);
			trace("length:" + bytes.length);
			trace(HexUtil.toHexString(bytes));
		}
		
	}
	
}