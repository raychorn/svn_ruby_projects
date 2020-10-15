package com.bigfix.dss.view.graphics.canvas.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class SelectedReportElementEvent extends Event {

		public function SelectedReportElementEvent(type:String, element:*, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.element = element;
		}
		
        public static const TYPE_SELECTED_REPORT_ELEMENT:String = "selectedReportElement";
        
        public var element:*;

        override public function clone():Event {
            return new SelectedReportElementEvent(type, element);
        }
	}
}