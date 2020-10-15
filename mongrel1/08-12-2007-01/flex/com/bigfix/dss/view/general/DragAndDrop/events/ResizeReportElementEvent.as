package com.bigfix.dss.view.general.DragAndDrop.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class ResizeReportElementEvent extends Event {

		public function ResizeReportElementEvent(type:String, child:DisplayObject, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.child = child;
		}
		
        public static const TYPE_RESIZE_REPORT_ELEMENT_COMPLETE:String = "resizeReportElementComplete";
        
        public var child:DisplayObject;

        override public function clone():Event {
            return new ResizeReportElementEvent(type, child);
        }
	}
}