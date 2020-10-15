package com.bigfix.dss.view.graphics.sprites.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class MovedSpriteEvent extends Event {

		public function MovedSpriteEvent(type:String, x:Number, y:Number, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.x = x;
			this.y = y;
		}
		
		public var x:Number;
		public var y:Number;
		
        public static const TYPE_MOVED_SPRITE:String = "movedSprite";
        
        override public function clone():Event {
            return new MovedSpriteEvent(type, x, y);
        }
	}
}