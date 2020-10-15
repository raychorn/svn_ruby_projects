package com.bigfix.dss.event {
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class SetReportScheduleEvent extends CairngormEvent {
		public static const EVENT_SET_REPORT_SCHEDULE:String = "setReportSchedule";

		public var _resultHandler:Function;
		public var _faultHandler:Function;
		public var _schedule:String;
		public var _report_id:int;
		
		public function SetReportScheduleEvent(report_id:int, schedule:String, resultHandler:Function = null, faultHandler:Function = null) {
			super(EVENT_SET_REPORT_SCHEDULE);
			this._resultHandler = resultHandler;
			this._faultHandler = faultHandler;
			this._schedule = schedule;
			this._report_id = report_id;
		}

		override public function clone():Event {
			return new SetReportScheduleEvent(_report_id, _schedule, _resultHandler, _faultHandler);
		}
	}
}