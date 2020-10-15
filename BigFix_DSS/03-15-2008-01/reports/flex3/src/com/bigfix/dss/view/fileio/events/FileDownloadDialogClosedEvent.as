package com.bigfix.dss.view.fileio.events {
  import flash.events.Event;

	public class FileDownloadDialogClosedEvent extends Event {
	
		public function FileDownloadDialogClosedEvent(type:String) {
			super(type);
		}
		
		public static var type_FILE_DOWNLOAD_DIALOG_CLOSED:String = "fileDownloadDialogClosed";
		  
		override public function clone(): Event {
		  return new FileDownloadDialogClosedEvent(type);
		}
	}
}
