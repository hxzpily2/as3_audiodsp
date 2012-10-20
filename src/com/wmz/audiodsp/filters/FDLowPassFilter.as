package com.wmz.audiodsp.filters 
{
	import com.wmz.audiodsp.math.FFTResult;
	/**
	 * ...
	 * @author morriswmz
	 */
	public class FDLowPassFilter implements IFreqDomainFilter 
	{
		public var cutoffFreq:Number;
		private var cutoffIndex:int;
		private var ffts:FFTResult;
		
		public function FDLowPassFilter(fc:Number, fs:Number, n:int) 
		{
			cutoffFreq = fc;
			cutoffIndex = fc * 2 * n / fs;
			ffts = new FFTResult(new Vector.<Number>(), new Vector.<Number>());
		}
		
		public function apply(p_ffts:FFTResult, clone:Boolean = false):FFTResult {
			var i:int;
			if (clone) {
				return ffts;
			} else {
				for (i = 0; i < cutoffIndex; i++) {
					
				}
				return null;
			}
		}
		
	}

}