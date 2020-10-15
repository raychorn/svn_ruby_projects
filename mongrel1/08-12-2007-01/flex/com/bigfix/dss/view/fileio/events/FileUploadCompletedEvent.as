package com.bigfix.dss.view.fileio.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class FileUploadCompletedEvent extends Event {

		public function FileUploadCompletedEvent(type:String, data:Object, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
		
        public static const TYPE_FILE_UPLOAD_COMPLETE:String = "fileUploadComplete";
        
        public var data:Object;

        override public function clone():Event {
            return new FileUploadCompletedEvent(type, data);
        }
	}
}