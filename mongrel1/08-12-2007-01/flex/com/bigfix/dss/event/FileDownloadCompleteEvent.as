package com.bigfix.dss.event {
  import flash.events.Event;

	public class FileDownloadCompleteEvent extends Event {
	
		public static var FILE_DOWNLOAD_COMPLETE:String = "fileDownloadComplete";
		  
		public var sourceFileName:String;
		
		public function FileDownloadCompleteEvent(type:String, sourceFileName:String) {
			super(type);
			this.sourceFileName = sourceFileName;
		}
		
		override public function clone(): Event {
		  return new FileDownloadCompleteEvent(type, sourceFileName);
		}
	}
}
