package com.bigfix.dss.view.report.events {
	import flash.events.Event;

	public class SignalUpdateReportsEvent extends Event {

		public function SignalUpdateReportsEvent(type:String, schedule:String, destination:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.schedule = schedule;
			this.destination = destination;
		}
		
        public static const TYPE_SIGNAL_UPDATE_REPORTS:String = "signalUpdateReports";
        
        public var schedule:String;
        public var destination:String;
        
        override public function clone():Event {
            return new SignalUpdateReportsEvent(type, schedule, destination);
        }
	}
}