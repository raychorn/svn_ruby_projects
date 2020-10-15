package com.bigfix.dss.view.graphics.RubberBand.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class MouseDownReportElementEvent extends Event {

		public function MouseDownReportElementEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_MOUSE_REPORT_ELEMENT:String = "mouseDownReportElement";
        
        override public function clone():Event {
            return new MouseDownReportElementEvent(type);
        }
	}
}