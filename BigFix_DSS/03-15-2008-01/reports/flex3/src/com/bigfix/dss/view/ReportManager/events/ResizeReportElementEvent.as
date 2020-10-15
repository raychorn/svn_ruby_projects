package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;

	public class ResizeReportElementEvent extends Event {

		public function ResizeReportElementEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_RESIZE_REPORT_ELEMENT:String = "resizeReportElement";
        
        override public function clone():Event {
            return new ResizeReportElementEvent(type);
        }
	}
}