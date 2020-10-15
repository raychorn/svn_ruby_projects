package com.bigfix.dss.view.graphics.canvas.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class BeginAddingElementsToReportEvent extends Event {

		public function BeginAddingElementsToReportEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_BEGIN_ADDING_ELEMENTS_TO_REPORT:String = "beginAddingElementsToReport";
        
        override public function clone():Event {
            return new BeginAddingElementsToReportEvent(type);
        }
	}
}