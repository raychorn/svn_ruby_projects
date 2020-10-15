package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;

	import com.bigfix.dss.util.DSS;
	import flash.utils.*;
	import com.bigfix.dss.event.SetReportScheduleEvent;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class SetReportScheduleCommand implements ICommand, IResponder {
		private var resultHandler:Function;
		private var faultHandler:Function;
		private var schedule:String;
		private var report_id:int;

		public function execute(event:CairngormEvent):void {
			if (event is SetReportScheduleEvent) {
				this.resultHandler = SetReportScheduleEvent(event)._resultHandler;
				this.faultHandler = SetReportScheduleEvent(event)._faultHandler;
				this.schedule = SetReportScheduleEvent(event)._schedule;
				this.report_id = SetReportScheduleEvent(event)._report_id;
			}
			if (!schedule) {
				throw new Error("SetReportScheduleCommand.execute(): You must specify the schedule!");
			}
			if (!report_id) {
				throw new Error("SetReportScheduleCommand.execute(): You must specify the report_id!");
			}
			DSS.svc("reportService").setSchedule(report_id, schedule).addResponder(this);
		}

		public function result(data:Object):void {
			if (this.resultHandler is Function) {
				try { this.resultHandler(data.result); } catch (err:Error) { AlertPopUp.error(err.toString(), "AddWidgetToDashboardCommand failed in result handler.") }
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			if (this.faultHandler is Function) {
				try { this.faultHandler(info); } catch (err:Error) { AlertPopUp.error(err.toString(), "AddWidgetToDashboardCommand failed in error handler.") }
			}
		}
	}
}