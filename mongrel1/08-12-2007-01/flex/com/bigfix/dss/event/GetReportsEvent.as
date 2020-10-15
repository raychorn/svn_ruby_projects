package com.bigfix.dss.event {
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetReportsEvent extends CairngormEvent {
		public static var EVENT_GET_REPORTS:String = "getReports";

		public var _callback:Function;
		
		public function GetReportsEvent(callback:Function = null) {
			super(EVENT_GET_REPORTS);
			this._callback = callback;
		}

		override public function clone():Event {
			return new GetReportsEvent();
		}
	}
}