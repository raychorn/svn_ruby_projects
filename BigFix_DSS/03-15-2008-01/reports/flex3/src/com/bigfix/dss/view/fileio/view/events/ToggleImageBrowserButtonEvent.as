package com.bigfix.dss.view.fileio.view.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class ToggleImageBrowserButtonEvent extends Event {

		public function ToggleImageBrowserButtonEvent(type:String, buttonID:String, enabled:Boolean, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.buttonID = buttonID;
			this.enabled = enabled;
		}
		
        public static const TYPE_TOGGLE_IMAGE_BROWSER_BUTTON:String = "toggleImageBrowserButton";
        
        public var buttonID:String;
        public var enabled:Boolean;
        
        override public function clone():Event {
            return new ToggleImageBrowserButtonEvent(type, buttonID, enabled);
        }
	}
}