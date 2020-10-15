package com.bigfix.dss.event {
  import flash.events.Event;

	public class SortOrderChangedEvent extends Event {
	
		public static var SORT_ORDER_CHANGED:String = "sortOrderChanged";
		  
		public var sortOrder:String;
		
		public function SortOrderChangedEvent(type:String, sortOrder:String) {
			super(type);
			this.sortOrder = sortOrder;
		}
		
		override public function clone(): Event {
		  return new SortOrderChangedEvent(type, sortOrder);
		}
	}
}
