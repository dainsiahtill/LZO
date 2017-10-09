package com.titan.utils 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author messiah
	 */
	public class HexUtil 
	{
		public static function toHexString(bytes:ByteArray, isUpperCase:Boolean = false):String
		{
			bytes.position = 0;
			
			var str:String = "";
			for (var i:int = 0; i < bytes.length; i++) 
			{
				var b:int = bytes.readUnsignedByte();
				var bs:String = b.toString(16);
				if (bs.length == 1)
				{
					bs = "0" + bs;
				}
				if (isUpperCase)
				{
					bs = bs.toUpperCase();
				}
				str += bs;
			}
			return str;
		}
	}

}