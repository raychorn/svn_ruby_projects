package com.bigfix.dss.view.fileio.events {
  import flash.events.Event;

	public class NoImagesOnServerEvent extends Event {
	
		public function NoImagesOnServerEvent(type:String) {
			super(type);
		}
		
		public static var type_NO_IMAGES_ON_SERVER:String = "noImagesOnServer";
		  
		override public function clone(): Event {
		  return new NoImagesOnServerEvent(type);
		}
	}
}
