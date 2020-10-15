package com.bigfix.dss.view.general.widgets.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class RemovedImageElementEvent extends Event {

		public function RemovedImageElementEvent(type:String, url:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.url = url;
		}
		
        public static const TYPE_REMOVED_IMAGE_ELEMENT:String = "removedImageElement";
        
        public var url:String;

        override public function clone():Event {
            return new RemovedImageElementEvent(type, url);
        }
	}
}