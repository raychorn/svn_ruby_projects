package com.bigfix.dss.view.graphics.RubberBand.events {
	import flash.events.Event;

	public class ClosedReportElementEditorEvent extends Event {

		public function ClosedReportElementEditorEvent(type:String, id:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.id = id;
		}
		
        public static const TYPE_CLOSED_REPORT_ELEMENT:String = "closedReportElement";
        
        public var id:String;

        override public function clone():Event {
            return new ClosedReportElementEditorEvent(type, id);
        }
	}
}