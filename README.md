# LZO
Pure as3 implementation of the LZO compression algorithm.

```Actionscript
//for test

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
```
