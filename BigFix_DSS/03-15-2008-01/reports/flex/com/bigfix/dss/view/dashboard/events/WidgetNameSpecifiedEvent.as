package com.bigfix.dss.view.dashboard.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import com.bigfix.dss.vo.WidgetVO;

	public class WidgetNameSpecifiedEvent extends Event {

		public function WidgetNameSpecifiedEvent(type:String, name:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.name = name;
		}
		
        public static const TYPE_WIDGET_NAME_SPECIFIED:String = "widgetNameSpecified";
        
        public var name:String;

        override public function clone():Event {
            return new WidgetNameSpecifiedEvent(type, name);
        }
	}
}