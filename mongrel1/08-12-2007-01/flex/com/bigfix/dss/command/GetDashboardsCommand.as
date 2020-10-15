package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;

	public class GetDashboardsCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
		  DSS.svc("dashboardService").getDashboards(DSS.model.user).onResult(this.result).onFault(this.fault);
		}

		public function result(data:Object):void {
			DSS.model.dashboards = new ArrayCollection(data.result);
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Service Fault");
		}
	}
}