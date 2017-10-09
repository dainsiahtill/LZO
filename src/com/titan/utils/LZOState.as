package com.titan.utils 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author messiah
	 */
	public class LZOState 
	{
		internal var inputBuffer:Vector.<uint>;
		internal var outputBuffer:Vector.<uint>;
	
		public function LZOState(bytes:ByteArray) 
		{
			bytes.position = 0;
			
			inputBuffer = new Vector.<uint>(bytes.bytesAvailable);
			
			var index:int = 0;
			while (bytes.bytesAvailable)
			{
				inputBuffer[index++] = bytes.readUnsignedByte();
			}
		}
		
		public function toOutputBytes():ByteArray 
		{
			if (outputBuffer)
			{
				var bytes:ByteArray = new ByteArray();
				for (var i:int = 0; i < outputBuffer.length; i++) 
				{
					bytes.writeByte(outputBuffer[i]);
				}
				return bytes;
			}
			return null;
		}
		
	}

}