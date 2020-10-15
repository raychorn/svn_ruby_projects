package com.bigfix.dss.view.ReportManager.events {
	import flash.events.Event;

	public class MovedReportElementEvent extends Event {

		public function MovedReportElementEvent(type:String, id:String, x:Number, y:Number, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.id = id;
			this.x = x;
			this.y = y;
		}
		
        public static const TYPE_MOVED_REPORT_ELEMENT:String = "movedReportElement";
        
        public var id:String;
        public var x:Number;
        public var y:Number;

        override public function clone():Event {
            return new MovedReportElementEvent(type, id, x, y);
        }
	}
}