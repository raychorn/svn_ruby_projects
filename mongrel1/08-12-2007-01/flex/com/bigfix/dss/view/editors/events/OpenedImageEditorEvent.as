package com.bigfix.dss.view.editors.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class OpenedImageEditorEvent extends Event {

		public function OpenedImageEditorEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_OPENED_IMAGE_EDITOR:String = "openedImageEditor";
        
        override public function clone():Event {
            return new OpenedImageEditorEvent(type);
        }
	}
}