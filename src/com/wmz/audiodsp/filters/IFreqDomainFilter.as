package com.wmz.audiodsp.filters 
{
	import com.wmz.audiodsp.math.FFTResult;
	
	/**
	 * ...
	 * @author morriswmz
	 */
	public interface IFreqDomainFilter 
	{
		function apply(p_ffts:FFTResult, clone:Boolean = false):FFTResult;
	}
	
}