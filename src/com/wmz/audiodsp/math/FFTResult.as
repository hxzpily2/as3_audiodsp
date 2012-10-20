package com.wmz.audiodsp.math 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class FFTResult 
	{
		public var re:Vector.<Number>;
		public var im:Vector.<Number>;
		
		public function FFTResult(p_re:Vector.<Number>, p_im:Vector.<Number>) 
		{
			re = p_re;
			im = p_im;
		}
		
		public function getAmplitude(divider:int=1, limit:int=-1,normalize:Boolean=false, useDB:Boolean=false):Vector.<Number> {
			var ret:Vector.<Number> = new Vector.<Number>();
			var max:Number = -1;
			var n:int = (limit > 0) ? Math.min(re.length, limit) : re.length;
			var i:int;
			var j:int;
			for (i = 0, j = 0; i < n;j++, i+=divider) {
				ret[j] = re[i] * re[i] + im[i] * im[i];
				if (max < ret[j]) max = ret[j];
			}
			if (useDB) {
				if (max > 0) {
					max = 1.0 / max; // inv max for speed
					for (i = 0; i < ret.length; i++) {
						ret[i] = 10 * Math.log(ret[i] * max + 1e-10) * Math.LOG10E;
					}
				}
			} else {
				if (normalize && max > 0) {
					for (i = 0; i < ret.length; i++) {
						ret[i] /= max;
					}
				}
			}
			
			return ret;
		}
		
	}

}