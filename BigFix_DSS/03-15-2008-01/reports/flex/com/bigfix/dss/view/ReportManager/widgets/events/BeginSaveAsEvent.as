package com.bigfix.dss.view.ReportManager.widgets.events {
	import flash.events.Event;

	public class BeginSaveAsEvent extends BeginPrintJobEvent {

		public function BeginSaveAsEvent(type:String, sourceType:String, destType:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, sourceType, destType, bubbles, cancelable);
		}
		
        public static const TYPE_SAVE_AS:String = "saveAs";
        
        public static const const_source_reportBuilder:String = "reportBuilder";
        public static const const_dest_image:String = "image";
        public static const const_dest_pdf:String = "pdf";

        override public function clone():Event {
            return new BeginSaveAsEvent(type, this.sourceType, this.destType);
        }
	}
}