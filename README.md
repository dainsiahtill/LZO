# LZO
Pure as3 implementation of the LZO compression algorithm.
//for test
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
