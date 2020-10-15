package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;
	import flash.utils.*;
	import com.bigfix.dss.vo.ReportVO;
	import com.bigfix.dss.event.GetReportsEvent;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class GetReportsCommand implements ICommand, IResponder {
		public static var svc:*;
		
		private var _callback:Function;
		
		public function execute(event:CairngormEvent):void {
			svc = DSS.svc("reportService");
			if (event is GetReportsEvent) {
				this._callback = GetReportsEvent(event)._callback;
			}
			svc.getReports(DSS.model.user).addResponder(this);
		}

		public function result(data:Object):void {
			var vo:ReportVO = new ReportVO();
			DSS.model.reports = new ArrayCollection(data.result);
			if (this._callback != null) {
				try { this._callback(); } 
					catch (err:Error) { 
						AlertPopUp.error(err.toString(), "ERROR from GetReportsCommand Result Callback.");
					}
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Unable to retrieve reports");
		}
	}
}