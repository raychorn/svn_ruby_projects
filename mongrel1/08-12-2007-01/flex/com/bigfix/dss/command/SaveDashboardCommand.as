package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.vo.DashboardVO;
	import com.bigfix.dss.util.DSS;
	import flash.utils.*;

	public class SaveDashboardCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		public var dashboard:DashboardVO;

		public function execute(event:CairngormEvent):void {
			if (!dashboard) {
				throw new Error("SaveDashboardCommand.execute(): You must specify the dashboard!");
			}
			
			DSS.svc("dashboardService").saveDashboard(dashboard).addResponder(this);
		}

		public function result(data:Object):void {
			if (this.resultHandler is Function) {
				this.resultHandler(data.result);
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Unable to save your dashboard!");
			if (this.faultHandler is Function) {
				this.faultHandler(info);
			}
		}
	}
}