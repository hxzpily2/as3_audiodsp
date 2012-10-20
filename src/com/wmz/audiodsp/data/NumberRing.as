package com.wmz.audiodsp.data 
{
	/**
	 * ...
	 * @author morriswmz
	 */
	public final class NumberRing 
	{
		public var head:NumberRingNode;
		
		private static var garbagePool:NumberRingNode = new NumberRingNode(-1);
		
		public function NumberRing(vec:Vector.<Number> = null) 
		{
			if (vec) {
				for (var i:int = 0, n:int = vec.length; i < n; i++) {
					insert(vec[n - i]);
				}
			}
		}
		
		public function insert(data:Number):NumberRingNode {
			var newNode:NumberRingNode;
			if (head) {
				if (garbagePool.next) {
					newNode = garbagePool.next;
					newNode.data = data;
					garbagePool.next = newNode.next;
				} else {
					newNode = new NumberRingNode(data);
				}
				newNode.next = head.next;
				head.next = newNode;
			} else {
				head = new NumberRingNode(data);
				head.next = head;
				newNode = head;
			}
			return newNode;
		}
		
		public function removeFirst():Number {
			var deadNode:NumberRingNode = head.next;
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
		
		public function seek(index:int):NumberRingNode {
			var pos:int = 0;
			var node:NumberRingNode = head;
			while (pos < index) {
				node = node.next;
				pos++;
			}
			return node;
		}
		
		public function dispose():void {
			while (head) removeFirst();
		}
		
	}

}