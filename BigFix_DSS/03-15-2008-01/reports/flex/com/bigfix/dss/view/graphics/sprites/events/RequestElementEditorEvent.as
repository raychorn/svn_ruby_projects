package com.bigfix.dss.view.graphics.sprites.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class RequestElementEditorEvent extends Event {

		public function RequestElementEditorEvent(type:String, element:*, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.element = element;
		}
		
		public var element:*;
		
        public static const TYPE_REQUEST_ELEMENT_EDITOR:String = "requestElementEditor";
        
        override public function clone():Event {
            return new RequestElementEditorEvent(type, element);
        }
	}
}