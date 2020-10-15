package com.bigfix.dss.view.general.buttons.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class ClickToggleButtonEvent extends Event {

		public function ClickToggleButtonEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_CLICK_TOGGLE_BUTTON:String = "clickToggleButton";
        
        override public function clone():Event {
            return new ClickToggleButtonEvent(type);
        }
	}
}