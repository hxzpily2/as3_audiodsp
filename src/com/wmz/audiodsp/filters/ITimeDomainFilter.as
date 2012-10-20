package com.wmz.audiodsp.filters 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public interface ITimeDomainFilter 
	{
		
		function apply(p_seq:Vector.<Number>, clone:Boolean = false):Vector.<Number>;
		function reset():void;
		
	}

}