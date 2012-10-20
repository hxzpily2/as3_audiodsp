package com.wmz.audiodsp.data 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class IntRing 
	{
		public var head:IntRingNode;
		
		private static var garbagePool:IntRingNode = new IntRingNode(-1);
		
		public function IntRing(vec:Vector.<int> = null) 
		{
			if (vec) {
				for (var i:int = 0, n:int = vec.length; i < n; i++) {
					insert(vec[n - i]);
				}
			}
		}
		
		public function insert(data:int):void {
			var newNode:IntRingNode;
			if (head) {
				if (garbagePool.next) {
					newNode = garbagePool.next;
					newNode.data = data;
					garbagePool.next = newNode.next;
				} else {
					newNode = new IntRingNode(data);
				}
				newNode.next = head.next;
				head.next = newNode;
			} else {
				head = new IntRingNode(data);
				head.next = head;
			}
		}
		
		public function removeFirst():int {
			var deadNode:IntRingNode = head.next;
			if (deadNode.next != deadNode) {
				// not head
				head.next = deadNode.next;
			} else {
				// head
				head = null;
			}
			deadNode.next = garbagePool.next;
			garbagePool.next = deadNode;
			return deadNode.data;
		}
		
		public function dispose():void {
			while (head) removeFirst();
		}
		
	}

}