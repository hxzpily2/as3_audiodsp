package com.wmz.audiodsp.math 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class FFT 
	{
		private static var sinTable:Vector.<Number>;
		private static var cosTable:Vector.<Number>;
		private static var lastLength:int;
		
		public static var FFTTime:Number = 0;
		private static var fftTotalTime:Number = 0;
		public static var fftCount:Number = 0;
		
		public function FFT() 
		{
			
		}
		
		/**
		 * In place bit reversion
		 * @param	p_seq
		 */
		public static function bitReverse(p_seq:Vector.<Number>):Vector.<Number> {
			var n:int = p_seq.length;
			var n2:int = n >> 1;
			var ret:Vector.<Number> = new Vector.<Number>(n);
			var k:int; // current index inside current group
			var l:int; // current group size, 2^E
			var i:int; // current sequence index
			var r:int; // offset, 2^(log2N - E - 1)
			var j:Vector.<int> = new Vector.<int>(n >> 1); // swap index table
			var tmp:Number;
			// clone input
			for (i = 0; i < n; i++) {
				ret[i] = p_seq[i];
			}
			// init
			j[0] = 0; j[1] = n2;
			tmp = ret[1];
			ret[1] = ret[n2];
			ret[n2] = tmp;
			for (i = 2, l = 2, r = n2 >> 1; r > 0; l <<= 1, r >>= 1) {
				for (k = 0; k < l; k++, i++) {
					j[i] = j[k] + r;
					if (i < j[i]) {
						tmp = ret[i];
						ret[i] = ret[j[i]];
						ret[j[i]] = tmp;
					}
				}
			}
			return ret;
		}
		
		private static function generateTable(p_n:int):void {
			if (lastLength == p_n) return;
			trace('new table generated');
			var i:int;
			var theta:Number = 0.0;
			var thetaInc:Number = (Math.PI + Math.PI) / p_n;
			sinTable = new Vector.<Number>(1 + p_n >> 1);
			cosTable = new Vector.<Number>(1 + p_n >> 1);
			sinTable[0] = 0.0;
			cosTable[0] = 1.0
			for (i = 1; i <= p_n >> 1; i++) {
				theta += thetaInc;
				sinTable[i] = Math.sin(theta);
				cosTable[i] = Math.cos(theta);
			}
			lastLength = p_n;
		}
		
		public static function compute(p_re:Vector.<Number>, p_im:Vector.<Number> = null, forward:Boolean = true):FFTResult {
			var n:int = p_re.length;
			var inv_n:Number;
			// check sequence
			if (!((n != 0) && (n & (n - 1)) == 0)) {
				throw new Error('Vector length must be a power of 2.');
			}
			var timeStart:Number = getTimer();
			// init result vector
			var resr:Vector.<Number> = bitReverse(p_re);
			var resi:Vector.<Number>;
			if (!p_im) {
				resi = new Vector.<Number>(n);
				for (var i:int = 0; i < n; i++) {
					resi[i] = 0.0;
				}
			} else {
				resi = bitReverse(p_im);
			}
			// fft
			var nWings:int = 1;
			var istep:int;
			var pos:int;
			var posStep:int = n >> 1;
			var wr:Number, wi:Number;
			var wpr:Number, wpi:Number;
			var theta:Number;
			var m:int, k:int, l:int;
			var pi:Number = forward ? -Math.PI:Math.PI;
			var tmpi:Number, tmpr:Number;
			
			// generateTable(n);
			
			while (n > nWings) {
				istep = nWings + nWings;
				theta = pi / nWings;
				wpi = Math.sin(theta);
				wpr = Math.sin(theta / 2.0);
				wpr = 1.0 - 2.0 * wpr * wpr;
				wi = 0;
				wr = 1.0;
				for (m = 1; m <= nWings; m++) {
					for (k = m - 1; k < n; k += istep) {
						l = k + nWings;
						tmpr = wr * resr[l] - wi * resi[l];
						tmpi = wr * resi[l] + wi * resr[l];
						resr[l] = resr[k] - tmpr;
						resi[l] = resi[k] - tmpi;
						resr[k] = resr[k] + tmpr;
						resi[k] = resi[k] + tmpi;
					}
					tmpr = wr;
					wr = wr * wpr - wi * wpi;
					wi = wr * wpi + wi * wpr;
				}
				posStep >>= 1;
				nWings = istep;
			}
			// scaling
			if (!forward) {
				inv_n = 1.0 / n;
				for (m = 0; m < n;m++) {
					resr[m] *= inv_n;
					resi[m] *= inv_n;
				}
			}
			fftTotalTime += getTimer() - timeStart;
			fftCount++;
			FFTTime = fftTotalTime / fftCount;
			return new FFTResult(resr, resi);
		}
		
		public static function computeTable(p_re:Vector.<Number>, p_im:Vector.<Number> = null, forward:Boolean = true):FFTResult {
			var n:int = p_re.length;
			var inv_n:Number;
			// check sequence
			if (!((n != 0) && (n & (n - 1)) == 0)) {
				throw new Error('Vector length must be a power of 2.');
			}
			var timeStart:Number = getTimer();
			// init result vector
			var resr:Vector.<Number> = bitReverse(p_re);
			var resi:Vector.<Number>;
			if (!p_im) {
				resi = new Vector.<Number>(n);
				for (var i:int = 0; i < n; i++) {
					resi[i] = 0.0;
				}
			} else {
				resi = bitReverse(p_im);
			}
			// fft
			var nWings:int = 1;
			var istep:int;
			var pos:int;
			var posStep:int = n >> 1;
			var wr:Number, wi:Number;
			var m:int, k:int, l:int;
			var pi:Number = forward ? -Math.PI:Math.PI;
			var tmpi:Number, tmpr:Number;
			
			generateTable(n);
			
			while (n > nWings) {
				istep = nWings + nWings;
				pos = 0;
				wi = sinTable[pos];
				wr = cosTable[pos];
				for (m = 1; m <= nWings; m++) {
					for (k = m - 1; k < n; k += istep) {
						l = k + nWings;
						tmpr = wr * resr[l] - wi * resi[l];
						tmpi = wr * resi[l] + wi * resr[l];
						resr[l] = resr[k] - tmpr;
						resi[l] = resi[k] - tmpi;
						resr[k] = resr[k] + tmpr;
						resi[k] = resi[k] + tmpi;
					}
					tmpr = wr;
					pos += posStep;
					wr = cosTable[pos];
					wi = sinTable[pos];
				}
				posStep >>= 1;
				nWings = istep;
			}
			// scaling
			if (!forward) {
				inv_n = 1.0 / n;
				for (m = 0; m < n;m++) {
					resr[m] *= inv_n;
					resi[m] *= inv_n;
				}
			}
			fftTotalTime += getTimer() - timeStart;
			fftCount++;
			FFTTime = fftTotalTime / fftCount;
			return new FFTResult(resr, resi);
		}
		
	}

}