package com.wmz.audiodsp.data 
{
	/**
	 * Linked list node of sound samples
	 * @author morriswmz
	 */
	public final class SampleData 
	{
		public var data:Number;
		public var prev:SampleData;
		public var next:SampleData;
		
		public function SampleData(p_data:Number = 0, p_prev:SampleData = null, p_next:SampleData = null) 
		{
			data = p_data;
			prev = p_prev;
			next = p_next;
		}
		
	}

}