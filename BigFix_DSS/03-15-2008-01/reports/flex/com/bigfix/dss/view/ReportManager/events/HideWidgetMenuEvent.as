package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;
	import flash.display.DisplayObjectContainer;

	public class HideWidgetMenuEvent extends Event {

		public function HideWidgetMenuEvent(type:String, widget:DisplayObjectContainer, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.widget = widget;
		}
		
        public static const TYPE_HIDE_WIDGET_MENU:String = "hideWidgetMenu";
        
        public var widget:DisplayObjectContainer;

        override public function clone():Event {
            return new HideWidgetMenuEvent(type, widget);
        }
	}
}