package com.bigfix.dss.view.fileio.view.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class FileDownloadCancelledEvent extends Event {

		public function FileDownloadCancelledEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_FILE_DOWNLOAD_CANCLLED:String = "fileDownloadCancelled";
        
        override public function clone():Event {
            return new FileDownloadCancelledEvent(type);
        }
	}
}