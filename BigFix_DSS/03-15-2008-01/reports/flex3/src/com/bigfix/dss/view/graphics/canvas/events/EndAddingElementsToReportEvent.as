package com.bigfix.dss.view.graphics.canvas.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class EndAddingElementsToReportEvent extends Event {

		public function EndAddingElementsToReportEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_END_ADDING_ELEMENTS_TO_REPORT:String = "endAddingElementsToReport";
        
        override public function clone():Event {
            return new EndAddingElementsToReportEvent(type);
        }
	}
}