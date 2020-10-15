package com.bigfix.dss.view.graphics.canvas.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class AddElementToReportCompletedEvent extends Event {

		public function AddElementToReportCompletedEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_ADD_ELEMENT_TO_REPORT_COMPLETED:String = "addElementToReportCompleted";
        
        override public function clone():Event {
            return new AddElementToReportCompletedEvent(type);
        }
	}
}