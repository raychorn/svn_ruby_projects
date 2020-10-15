package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class GetDashboardLayoutsCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
		  DSS.svc("dashboardService").getDashboardLayouts().onResult(this.result).onFault(this.fault);
		}

		public function result(data:Object):void {
			DSS.model.dashboard_layouts = new ArrayCollection(data.result);
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Service Fault");
		}
	}
}