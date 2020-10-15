package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;
	import flash.display.DisplayObjectContainer;

	public class IgnoreMouseUpEvent extends Event {

		public function IgnoreMouseUpEvent(type:String, widget:DisplayObjectContainer, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.widget = widget;
		}
		
        public static const TYPE_IGNORE_MOUSE_UP:String = "ignoreMouseUp";
        
        public var widget:DisplayObjectContainer;

        override public function clone():Event {
            return new IgnoreMouseUpEvent(type, widget);
        }
	}
}