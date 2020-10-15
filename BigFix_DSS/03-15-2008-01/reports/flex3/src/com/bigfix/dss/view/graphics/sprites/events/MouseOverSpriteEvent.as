package com.bigfix.dss.view.graphics.sprites.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class MouseOverSpriteEvent extends Event {

		public function MouseOverSpriteEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_MOUSE_OVER_SPRITE:String = "mouseOverSprite";
        
        override public function clone():Event {
            return new MouseOverSpriteEvent(type);
        }
	}
}