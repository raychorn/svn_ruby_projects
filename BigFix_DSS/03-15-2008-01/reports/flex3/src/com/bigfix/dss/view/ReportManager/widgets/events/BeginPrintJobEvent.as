package com.bigfix.dss.view.ReportManager.widgets.events {
	import flash.events.Event;

	public class BeginPrintJobEvent extends Event {

		public function BeginPrintJobEvent(type:String, sourceType:String, destType:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.sourceType = sourceType;
			this.destType = destType;
		}
		
        public static const TYPE_BEGIN_PRINT_JOB:String = "beginPrintJob";

        public static const const_source_reportBuilder:String = "reportBuilder";
        public static const const_dest_printer:String = "printer";
        
        public var sourceType:String;
        public var destType:String;
        
        override public function clone():Event {
            return new BeginPrintJobEvent(type, this.sourceType, this.destType);
        }
	}
}