package com.bigfix.dss.view.fileio.view.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class ImageSelectedEvent extends Event {

		public function ImageSelectedEvent(type:String, source:String, size:Array, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.source = source;
			this.size=  size;
		}
		
        public static const TYPE_IMAGE_SELECTED:String = "imageSelected";
        
        public var source:String;
        public var size:Array;
        
        override public function clone():Event {
            return new ImageSelectedEvent(type, source, size);
        }
	}
}