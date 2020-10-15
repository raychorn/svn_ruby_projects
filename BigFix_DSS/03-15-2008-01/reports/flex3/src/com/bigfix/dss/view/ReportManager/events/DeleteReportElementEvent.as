package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;
	import flash.display.DisplayObjectContainer;
	import com.bigfix.dss.view.ReportManager.canvas.WidgetCanvas;

	public class DeleteReportElementEvent extends Event {

		public function DeleteReportElementEvent(type:String, widget:*, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.widget = widget;
		}
		
        public static const TYPE_DELETE_REPORT_ELEMENT:String = "deleteReportElement";
        
        public var widget:*;

        override public function clone():Event {
            return new DeleteReportElementEvent(type, widget);
        }
	}
}