package com.bigfix.extensions.controls.events {
	import flash.events.Event;

	public class ClosedDashboardTabEvent extends Event {

		public function ClosedDashboardTabEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_CLOSED_DASHBOARD_TAB:String = "closedDashboardTab";
        
        override public function clone():Event {
            return new ClosedDashboardTabEvent(type);
        }
	}
}