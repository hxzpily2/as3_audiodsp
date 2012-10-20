package com.wmz.audiodsp.data 
{
	import flash.sampler.Sample;
	/**
	 * Linked list manager class for SampleData nodes
	 * @author morriswmz
	 */
	public final class SampleDataList 
	{
		public var head:SampleData;
		public var tail:SampleData;
		public var length:int;
		
		public function SampleDataList(p_init_length:int=0) 
		{
			// init sentinals
			head = new SampleData( -1.0);
			tail = new SampleData( -1.0);
			head.next = tail;
			tail.prev = head;
			length = 0;
			
			
		}
		
		public function push(p_data:Number):SampleData {
			length++;
			var ret:SampleData = new SampleData(p_data, tail.prev, tail);
			tail.prev.next = ret;
			tail.prev = ret;
			return ret;
		}
		
		public function shift(p_data:Number):SampleData {
			length++;
			var ret:SampleData = new SampleData(p_data, head, head.next);
			head.next.prev = ret;
			head.next = ret;
			return ret;
		}
		
		public function pop():SampleData {
			if (length == 0) return null;
			var ret:SampleData = tail.prev;
			ret.prev.next = tail;
			tail.prev = ret.prev;
			ret.next = null;
			ret.prev = null;
			length--;
			return ret;
		}
		
		public function unshift():SampleData {
			if (length == 0) return null;
			var ret:SampleData = head.next;
			ret.next.prev = head;
			head.next = ret.next;
			ret.prev = null;
			ret.next = null;
			length--;
			return ret;
		}
		
	}

}