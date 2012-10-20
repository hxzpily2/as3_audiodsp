package com.wmz.audiodsp.data 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class NumberRingNode 
	{
		public var data:Number;
		public var next:NumberRingNode;
		
		public function NumberRingNode(integer:Number = 0, nextNode:NumberRingNode = null) 
		{
			data = integer;
			next = nextNode;
		}
		
	}

}