package com.bigfix.dss.view.graphics.sprites.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class ResizeSpriteEvent extends Event {

		public function ResizeSpriteEvent(type:String, width:Number, height:Number, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.width = width;
			this.height = height;
		}
		
		public var width:Number;
		public var height:Number;
		
        public static const TYPE_RESIZE_SPRITE:String = "resizeSprite";
        
        override public function clone():Event {
            return new ResizeSpriteEvent(type, width, height);
        }
	}
}