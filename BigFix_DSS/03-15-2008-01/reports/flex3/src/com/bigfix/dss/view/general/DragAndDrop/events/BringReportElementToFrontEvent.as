package com.bigfix.dss.view.general.DragAndDrop.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class BringReportElementToFrontEvent extends Event {

		public function BringReportElementToFrontEvent(type:String, child:DisplayObject, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.child = child;
		}
		
        public static const TYPE_BRING_REPORT_ELEMENT_TO_FRONT:String = "bringReportElementToFront";
        
        public var child:DisplayObject;

        override public function clone():Event {
            return new BringReportElementToFrontEvent(type, child);
        }
	}
}