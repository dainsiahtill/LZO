package com.titan.utils 
{
	/**
	 * ...
	 * @author messiah
	 */
	public class LZO 
	{
		public static const OK:int = 0;
		public static const INPUT_OVERRUN:int = -4;
		public static const OUTPUT_OVERRUN:int = -5;
		public static const LOOKBEHIND_OVERRUN:int = -6;
		
		public static const EOF_FOUND:int = -999;
		
		private var blockSize:int = 128 * 1024;
		private var minNewSize:int = blockSize;
		private var maxSize:int = 0;
		
		private var ret:int = 0;

		private var buf:Vector.<uint> = null;

		private var out:Vector.<uint> = new Vector.<uint>(256 * 1024);
		private var cbl:int = 0;
		private var ipEnd:int = 0;
		private var opEnd:int = 0;
		private var t:int = 0;

		private var ip:int = 0;
		private var op:int = 0;
		private var pos:int = 0;
		private var len:int = 0;
		private var off:int = 0;

		private var dvHi:int = 0;
		private var dvLo:int = 0;
		private var dindex:int = 0;

		private var ii:int = 0;
		private var jj:int = 0;
		private var tt:int = 0;
		private var v:int = 0;
		private var ll:int;
		private var ti:int;
		private var l:int;
		private var prevIp:int;
		
		private var ipStart:int;

		private var dict:Vector.<uint> = new Vector.<uint>(16384);
		private var emptyDict:Vector.<uint> =  new Vector.<uint>(16384);

		private var skipToFirstLiteralFun:Boolean = false;
		private var returnNewBuffers:Boolean = true;
		
		private var state:LZOState;
		
		public function LZO() 
		{
			
		}
		
		private function extendBuffer():void
		{
	        var newBuffer:Vector.<uint> = new Vector.<uint>(this.minNewSize + (this.blockSize - this.minNewSize % this.blockSize));
			setArray(newBuffer, this.out);
			
	        this.out = newBuffer;
	        this.cbl = this.out.length;
	    };

	    private function match_next():void
		{
	        this.minNewSize = this.op + 3;
	        if(this.minNewSize > this.cbl) {this.extendBuffer();}

	        this.out[this.op++] = this.buf[this.ip++];
	        if(this.t > 1) {
	            this.out[this.op++] = this.buf[this.ip++];
	            if(this.t > 2) {
	                this.out[this.op++] = this.buf[this.ip++];
	            }
	        }

	        this.t = this.buf[this.ip++];
	    }

		private function match_done():int
		{
	        this.t = this.buf[this.ip - 2] & 3;
	        return this.t;
	    }

	    private function copy_match():void
		{
	        this.t += 2;
	        this.minNewSize = this.op + this.t;
	        if(this.minNewSize > this.cbl) {this.extendBuffer();}

	        do 
			{
	            this.out[this.op++] = this.out[this.pos++];
	        } while(--this.t > 0);
	    };
		
		private function copy_from_buf():void
		{
	    	this.minNewSize = this.op + this.t;
	        if(this.minNewSize > this.cbl) {this.extendBuffer();}

	        do 
			{
	            this.out[this.op++] = this.buf[this.ip++];
	        } while (--this.t > 0);
	    };

		private function match():int
		{
	        for (;; ) 
			{
	            if (this.t >= 64)
				{
	                this.pos = (this.op - 1) - ((this.t >> 2) & 7) - (this.buf[this.ip++] << 3);
	                this.t = (this.t >> 5) - 1;

	                this.copy_match();

	            }
				else if (this.t >= 32) 
				{
	                this.t &= 31;
	                if (this.t == 0) 
					{
	                    while (this.buf[this.ip] == 0)
						{
	                        this.t += 255;
	                        this.ip++;
	                    }
	                    this.t += 31 + this.buf[this.ip++];
	                }

	                this.pos = (this.op - 1) - (this.buf[this.ip] >> 2) - (this.buf[this.ip + 1] << 6);
	                this.ip += 2;

    	            this.copy_match();

	            } 
				else if (this.t >= 16)
				{
	                this.pos = this.op - ((this.t & 8) << 11);

	                this.t &= 7;
	                if (this.t == 0) {
	                    while (this.buf[this.ip] == 0) {
	                        this.t += 255;
	                        this.ip++;
	                    }
	                    this.t += 7 + this.buf[this.ip++];
	                }

	                this.pos -= (this.buf[this.ip] >> 2) + (this.buf[this.ip + 1] << 6);
	                this.ip += 2;

	                if (this.pos == this.op) 
					{
	                    this.state.outputBuffer = out.slice(0, this.op);
	                    return EOF_FOUND;

	                } 
					else 
					{
	                	this.pos -= 0x4000;
			            this.copy_match();
	                }

	            } 
				else
				{
	                this.pos = (this.op - 1) - (this.t >> 2) - (this.buf[this.ip++] << 2);
					
	                this.minNewSize = this.op + 2;
	                if(this.minNewSize > this.cbl) {this.extendBuffer();}

	                this.out[this.op++] = this.out[this.pos++];
	                this.out[this.op++] = this.out[this.pos];
	            }

	            if (this.match_done() == 0) 
				{
	                return OK;
	            }
	            this.match_next();
		    }
			
			return EOF_FOUND;
	    };

		public function decompress(state:LZOState):int
		{
	        this.state = state;

	        this.buf = this.state.inputBuffer;
	        this.cbl = this.out.length;
	        this.ipEnd = this.buf.length;
			
	        this.t = 0;
	        this.ip = 0;
	        this.op = 0;
	        this.pos = 0;

	        this.skipToFirstLiteralFun = false;
			
	        if (this.buf[this.ip] > 17) {
	            this.t = this.buf[this.ip++] - 17;
	            if (this.t < 4) {
	                this.match_next();
	                this.ret = this.match();
	                if(this.ret !== OK) {
	                    return this.ret == EOF_FOUND ? OK : this.ret;
	                }

	            } else 
				{
	                this.copy_from_buf();
	                this.skipToFirstLiteralFun = true;
	            }
	        }

	        for (;; ) 
			{
	            if (!this.skipToFirstLiteralFun) 
				{
	                this.t = this.buf[this.ip++];

	                if (this.t >= 16) {
	                    this.ret = this.match();
	                    if (this.ret !== OK) 
						{
	                        return this.ret == EOF_FOUND ? OK : this.ret;
	                    }
	                    continue;

	                } 
					else if (this.t == 0) 
					{
	                    while (this.buf[this.ip] == 0) 
						{
	                        this.t += 255;
	                        this.ip++;
	                    }
	                    this.t += 15 + this.buf[this.ip++];
	                }
					
	                this.t += 3;
	                this.copy_from_buf();
	            } else {
	                this.skipToFirstLiteralFun = false;
	            }

	            this.t = this.buf[this.ip++];
	            if (this.t < 16) 
				{
	                this.pos = this.op - (1 + 0x0800);
	                this.pos -= this.t >> 2;
	                this.pos -= this.buf[this.ip++] << 2;
					
	                this.minNewSize = this.op + 3;
	                if(this.minNewSize > this.cbl) {this.extendBuffer();}
	                this.out[this.op++] = this.out[this.pos++];
	                this.out[this.op++] = this.out[this.pos++];
	                this.out[this.op++] = this.out[this.pos];

	                if (this.match_done() == 0) 
					{
	                    continue;
	                } 
					else 
					{
	                    this.match_next();
	                }
	            }

	            this.ret = this.match();
	            if (this.ret !== OK) 
				{
	                return this.ret == EOF_FOUND ? OK : this.ret;
	            }
	        }

	        return OK;
	    }

		private function _compressCore():void
		{
	        this.ipStart = this.ip;
	        this.ipEnd = this.ip + this.ll - 20;
	        this.jj = this.ip;
	        this.ti = this.t;

	        this.ip += this.ti < 4 ? 4 - this.ti : 0;

	        this.ip += 1 + ((this.ip - this.jj) >> 5);

	        for (;; ) 
			{
	            if (this.ip >= this.ipEnd) 
				{
	                break;
	            }
				
	            this.dvLo = this.buf[this.ip] | (this.buf[this.ip + 1] << 8);
	            this.dvHi = this.buf[this.ip + 2] | (this.buf[this.ip + 3] << 8);
	            this.dindex = (((this.dvLo * 0x429d) >>> 16) + (this.dvHi * 0x429d) + (this.dvLo  * 0x1824) & 0xFFFF) >>> 2;

	            this.pos = this.ipStart + this.dict[this.dindex];

	            this.dict[this.dindex] = this.ip - this.ipStart;
	            if ((this.dvHi<<16) + this.dvLo != (this.buf[this.pos] | (this.buf[this.pos + 1] << 8) | (this.buf[this.pos + 2] << 16) | (this.buf[this.pos + 3] << 24))) {
	                this.ip += 1 + ((this.ip - this.jj) >> 5);
	                continue;
	            }
	            this.jj -= this.ti;
	            this.ti = 0;
	            this.v = this.ip - this.jj;

	            if (this.v !== 0) 
				{
	                if (this.v <= 3) 
					{
	                    this.out[this.op - 2] |= this.v;
	                    do 
						{
	                        this.out[this.op++] = this.buf[this.jj++];
	                    } 
						while (--this.v > 0);

	                } 
					else 
					{
	                    if (this.v <= 18) 
						{
	                        this.out[this.op++] = this.v - 3;

	                    } 
						else 
						{
	                        this.tt = this.v - 18;
	                        this.out[this.op++] = 0;
	                        while (this.tt > 255) 
							{
	                            this.tt -= 255;
	                            this.out[this.op++] = 0;
	                        }
	                        this.out[this.op++] = this.tt;
	                    }

	                    do 
						{
	                        this.out[this.op++] = this.buf[this.jj++];
	                    } 
						while (--this.v > 0);
	                }
	            }

	            this.len = 4;
				
	            if (this.buf[this.ip + this.len] == this.buf[this.pos + this.len]) 
				{
	                do 
					{
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    this.len += 1; if(this.buf[this.ip + this.len] !==  this.buf[this.pos + this.len]) {break;}
	                    if (this.ip + this.len >= this.ipEnd) 
						{
	                        break;
	                    }
	                } 
					while (this.buf[this.ip + this.len] ==  this.buf[this.pos + this.len]);
	            }
				
	            this.off = this.ip - this.pos;
	            this.ip += this.len;
	            this.jj = this.ip;
	            if (this.len <= 8 && this.off <= 0x0800) 
				{

	                this.off -= 1;

	                this.out[this.op++] = ((this.len - 1) << 5) | ((this.off & 7) << 2);
	                this.out[this.op++] = this.off >> 3;

	            } 
				else if (this.off <= 0x4000) 
				{
	                this.off -= 1;
	                if (this.len <= 33) 
					{
	                    this.out[this.op++] = 32 | (this.len - 2);
	                } 
					else 
					{
	                    this.len -= 33;
	                    this.out[this.op++] = 32;
	                    while (this.len > 255) {
	                        this.len -= 255;
	                        this.out[this.op++] = 0;
	                    }
	                    this.out[this.op++] = this.len;
	                }
	                this.out[this.op++] = this.off << 2;
	                this.out[this.op++] = this.off >> 6;
	            } 
				else 
				{
	                this.off -= 0x4000;
	                if (this.len <= 9) 
					{
	                    this.out[this.op++] = 16 | ((this.off >> 11) & 8) | (this.len - 2);

	                } 
					else 
					{
	                    this.len -= 9;
	                    this.out[this.op++] = 16 | ((this.off >> 11) & 8);

	                    while (this.len > 255) 
						{
	                        this.len -= 255;
	                        this.out[this.op++] = 0;
	                    }
	                    this.out[this.op++] = this.len;
	                }
	                this.out[this.op++] = this.off << 2;
	                this.out[this.op++] = this.off >> 6;
	            }
	        }
	        this.t = this.ll - ((this.jj - this.ipStart) - this.ti);
	    };

		public function compress(state:LZOState):int
		{
	        this.state = state;
	        this.ip = 0;
	        this.buf = this.state.inputBuffer;
	        this.maxSize = this.buf.length + Math.ceil(this.buf.length / 16) + 64 + 3;
	        if (this.maxSize > this.out.length) 
			{
	        	this.out = new Vector.<uint>(this.maxSize);
	        }
			
	        this.op = 0;
	        this.l = this.buf.length;
	        this.t = 0;

	        while (this.l > 20) {
	            this.ll = (this.l <= 49152) ? this.l : 49152;
	            if ((this.t + this.ll) >> 5 <= 0) {
	                break;
	            }

	            this.dict = new Vector.<uint>(this.emptyDict.length);

	            this.prevIp = this.ip;
	            this._compressCore();
	            this.ip = this.prevIp + this.ll;
	            this.l -= this.ll;
	        }
	        this.t += this.l;

	        if (this.t > 0) {
	            this.ii = this.buf.length - this.t;

	            if (this.op == 0 && this.t <= 238) {
	                this.out[this.op++] = 17 + this.t;

	            } else if (this.t <= 3) {
	                this.out[this.op-2] |= this.t;

	            } else if (this.t <= 18) {
	                this.out[this.op++] = this.t - 3;

	            } else {
	                this.tt = this.t - 18;
	                this.out[this.op++] = 0;
	                while (this.tt > 255) {
	                    this.tt -= 255;
	                    this.out[this.op++] = 0;
	                }
	                this.out[this.op++] = this.tt;
	            }

	            do {
	                this.out[this.op++] = this.buf[this.ii++];
	            } while (--this.t > 0);
	        }

	        this.out[this.op++] = 17;
	        this.out[this.op++] = 0;
	        this.out[this.op++] = 0;

	        this.state.outputBuffer = out.slice(0, this.op);
	        return OK;
	    }
		
		private function setArray(d:Vector.<uint>, s:Vector.<uint>):void
		{
			for (var i:int = 0; i < s.length; i++) 
			{
				d[i] = s[i];
			}
		}
	}
	
}