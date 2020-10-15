package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;
	import flash.display.DisplayObjectContainer;

	public class ShowWidgetMenuEvent extends Event {

		public function ShowWidgetMenuEvent(type:String, widget:DisplayObjectContainer, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.widget = widget;
		}
		
        public static const TYPE_SHOW_WIDGET_MENU:String = "showWidgetMenu";
        
        public var widget:DisplayObjectContainer;

        override public function clone():Event {
            return new ShowWidgetMenuEvent(type, widget);
        }
	}
}