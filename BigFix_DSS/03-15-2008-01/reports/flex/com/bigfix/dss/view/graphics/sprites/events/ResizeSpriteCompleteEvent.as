package com.bigfix.dss.view.graphics.sprites.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class ResizeSpriteCompleteEvent extends Event {

		public function ResizeSpriteCompleteEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_RESIZE_SPRITE_COMPLETE:String = "resizeSpriteComplete";
        
        override public function clone():Event {
            return new ResizeSpriteCompleteEvent(type);
        }
	}
}