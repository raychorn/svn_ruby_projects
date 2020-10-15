package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;

	public class MinimumReportElementSizeEvent extends Event {

		public function MinimumReportElementSizeEvent(type:String, id:String, width:Number, height:Number, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.id = id;
			this.width = width;
			this.height = height;
		}
		
        public static const TYPE_MINIMUM_REPORT_ELEMENT_SIZE:String = "minimumReportElementSize";
        
        public var id:String;
        public var width:Number;
        public var height:Number;

        override public function clone():Event {
            return new MinimumReportElementSizeEvent(type, id, width, height);
        }
	}
}