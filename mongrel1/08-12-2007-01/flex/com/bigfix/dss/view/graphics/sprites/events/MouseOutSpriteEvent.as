package com.bigfix.dss.view.graphics.sprites.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class MouseOutSpriteEvent extends Event {

		public function MouseOutSpriteEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_MOUSE_OUT_SPRITE:String = "mouseOutSprite";
        
        override public function clone():Event {
            return new MouseOutSpriteEvent(type);
        }
	}
}