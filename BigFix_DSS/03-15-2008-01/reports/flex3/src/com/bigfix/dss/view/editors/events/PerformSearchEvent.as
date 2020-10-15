package com.bigfix.dss.view.editors.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class PerformSearchEvent extends Event {

		public function PerformSearchEvent(type:String, text:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.text = text;
		}
		
        public static const TYPE_PERFORM_SEARCH:String = "performSearch";
        
        public var text:String;
        
        override public function clone():Event {
            return new PerformSearchEvent(type, text);
        }
	}
}