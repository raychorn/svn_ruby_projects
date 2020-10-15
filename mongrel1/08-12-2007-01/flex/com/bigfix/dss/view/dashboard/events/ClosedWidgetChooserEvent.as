package com.bigfix.dss.view.dashboard.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import com.bigfix.dss.vo.WidgetVO;

	public class ClosedWidgetChooserEvent extends Event {

		public function ClosedWidgetChooserEvent(type:String, widget:WidgetVO, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.widget = widget;
		}
		
        public static const TYPE_CLOSED_WIDGET_CHOOSER:String = "closedWidgetChooser";
        
        public var widget:WidgetVO;

        override public function clone():Event {
            return new ClosedWidgetChooserEvent(type, widget);
        }
	}
}