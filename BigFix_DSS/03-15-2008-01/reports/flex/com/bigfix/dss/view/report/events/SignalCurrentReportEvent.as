package com.bigfix.dss.view.report.events {
	import flash.events.Event;

	public class SignalCurrentReportEvent extends Event {

		public function SignalCurrentReportEvent(type:String, canLogout:Boolean, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.canLogout = canLogout;
		}
		
        public static const TYPE_SIGNAL_CURRENT_REPORT:String = "signalCurrentReport";
        
        public var canLogout:Boolean;
        
        override public function clone():Event {
            return new SignalCurrentReportEvent(type, canLogout);
        }
	}
}