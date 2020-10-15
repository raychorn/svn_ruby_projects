package com.bigfix.dss.view.editors.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class TextChangedEvent extends Event {

		public function TextChangedEvent(type:String, text:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.text = text;
		}
		
        public static const TYPE_TEXT_CHANGED:String = "textChanged";
        
        public var text:String;
        
        override public function clone():Event {
            return new TextChangedEvent(type, text);
        }
	}
}