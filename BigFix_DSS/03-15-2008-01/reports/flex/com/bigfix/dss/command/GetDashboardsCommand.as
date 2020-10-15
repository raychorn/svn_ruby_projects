package com.bigfix.dss.command {
	import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	import com.bigfix.dss.vo.DashboardFolderVO;
	import com.bigfix.dss.vo.DashboardHierarchyVO;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;

	public class GetDashboardsCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
		  DSS.svc("dashboardService").getDashboards(DSS.model.user).onResult(this.result).onFault(this.fault);
		}

		public function result(data:Object):void {
			var datum:Array = data.result;
			if (datum.length >= 1) {
				DSS.model.dashboards = new ArrayCollection(datum[0]);
			}
			if (datum.length >= 2) {
				DSS.model.folders = new ArrayCollection(datum[1]);
			}
			if (datum.length >= 3) {
				var dbf:DashboardFolderVO = new DashboardFolderVO();
				DSS.model.dashboard_folders = datum[2];
			}
			if (datum.length >= 4) {
				var dbh:DashboardHierarchyVO = new DashboardHierarchyVO();
				DSS.model.dashboard_hierarchies = datum[3];
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Service Fault");
		}
	}
}