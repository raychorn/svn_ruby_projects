package com.bigfix.dss.view.graphics.canvas.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class InitializeReportBuilderButtonsEvent extends Event {

		public function InitializeReportBuilderButtonsEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_INITIALIZE_REPORT_BUILDER_BUTTONS:String = "initializeReportBuilderButtons";
        
        override public function clone():Event {
            return new InitializeReportBuilderButtonsEvent(type);
        }
	}
}