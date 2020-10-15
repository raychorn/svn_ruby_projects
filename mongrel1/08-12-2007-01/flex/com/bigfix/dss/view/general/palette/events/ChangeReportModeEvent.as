package com.bigfix.dss.view.general.palette.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class ChangeReportModeEvent extends Event {

		public function ChangeReportModeEvent(type:String, elementType:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.elementType = elementType;
		}
		
        public static const TYPE_CHANGE_REPORT_MODE:String = "changeReportMode";
        
        public var elementType:String;

        override public function clone():Event {
            return new ChangeReportModeEvent(type, elementType);
        }
	}
}