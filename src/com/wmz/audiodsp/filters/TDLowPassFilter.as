package com.wmz.audiodsp.filters 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public class TDLowPassFilter 
	{
		
		private var b00:Number;
		private var b10:Number;
		private var b20:Number;
		private var a10:Number;
		private var a20:Number;
		
		private var x_n1:Number;
		private var x_n2:Number;
		private var y_n1:Number;
		private var y_n2:Number;
		
		private var buffer:Vector.<Number>;
		
		public function TDLowPassFilter(fc:Number, q:Number) 
		{
			var w0:Number = 2 * Math.PI * fc / 44100;
			var alpha:Number = Math.sin(w0) * 0.5 / q;
			var a0:Number = 1.0 + alpha;
			b00 = b20 = (0.5 - 0.5 * Math.cos(w0)) / a0;
			b10 = (1.0 - Math.cos(w0)) / a0;
			a10 = (-2.0 * Math.cos(w0)) / a0;
			a20 = (1.0 - alpha) / a0;
			x_n1 = 0;
			x_n2 = 0;
			y_n1 = 0;
			y_n2 = 0;
			buffer = new Vector.<Number>();
		}
		
		public function reset():void {
			x_n1 = 0;
			x_n2 = 0;
			y_n1 = 0;
			y_n2 = 0;
		}
		
		public function apply(p_seq:Vector.<Number>, clone:Boolean = false):Vector.<Number> {
			var i:int;
			var n:int = p_seq.length;
			var tx_n1:Number = x_n1;
			var tx_n2:Number = x_n2;
			x_n1 = p_seq[n - 1];
			x_n2 = p_seq[n - 2];
			var writeTarget:Vector.<Number> = clone ? buffer : p_seq;
			buffer[0] = b00 * (p_seq[0] + tx_n2) + b10 * tx_n1 - a10 * y_n1 - a20 * y_n2;
			buffer[1] = b00 * (p_seq[1] + tx_n1) + b10 * p_seq[0] - a10 * buffer[0] - a20 * y_n1;
			for (i = 2; i < n; i++) {
				buffer[i] = b00 * (p_seq[i] + p_seq[i - 2]) + b10 * p_seq[i - 1] - a10 * buffer[i - 1] - a20 * buffer[i - 2];
			}
			y_n1 = buffer[n - 1];
			y_n2 = buffer[n - 2];
			if (!clone) {
				for (i = 0; i < n; i++) {
					p_seq[i] = buffer[i];
				}
				return null;
			} else {
				return buffer;
			}
		}
		
	}

}