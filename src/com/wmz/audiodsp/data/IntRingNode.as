package com.wmz.audiodsp.data 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class IntRingNode 
	{
		public var data:int;
		public var next:IntRingNode;
		
		public function IntRingNode(num:int = 0, nextNode:IntRingNode = null) 
		{
			data = num;
			next = nextNode;
		}
		
	}

}