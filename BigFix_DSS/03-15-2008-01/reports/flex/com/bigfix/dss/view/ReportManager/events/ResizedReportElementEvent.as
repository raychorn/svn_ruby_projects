package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;

	public class ResizedReportElementEvent extends Event {

		public function ResizedReportElementEvent(type:String, id:String, width:Number, height:Number, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.id = id;
			this.width = width;
			this.height = height;
		}
		
        public static const TYPE_RESIZED_REPORT_ELEMENT:String = "resizedReportElement";
        
        public var id:String;
        public var width:Number;
        public var height:Number;

        override public function clone():Event {
            return new ResizedReportElementEvent(type, id, width, height);
        }
	}
}