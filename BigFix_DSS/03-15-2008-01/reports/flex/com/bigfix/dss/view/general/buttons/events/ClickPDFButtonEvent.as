package com.bigfix.dss.view.general.buttons.events {
	import flash.events.Event;

	public class ClickPDFButtonEvent extends Event {

		public function ClickPDFButtonEvent(type:String, data:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.data = data;
		}
		
        public static const TYPE_CLICK_PDF_BUTTON:String = "clickPDFButton";
        
        public var data:String;
        
        override public function clone():Event {
            return new ClickPDFButtonEvent(type, data);
        }
	}
}