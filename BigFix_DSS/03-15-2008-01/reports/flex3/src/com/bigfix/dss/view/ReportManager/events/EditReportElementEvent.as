package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;
	import com.bigfix.dss.view.ReportManager.canvas.WidgetCanvas;

	public class EditReportElementEvent extends Event {

		public function EditReportElementEvent(type:String, widget:*, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.widget = widget;
		}
		
        public static const TYPE_EDIT_REPORT_ELEMENT:String = "editReportElement";
        
        public var widget:*;
        
        override public function clone():Event {
            return new EditReportElementEvent(type, widget);
        }
	}
}