package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;

	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class RemoveDashboardCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		public var position:int;

		public function execute(event:CairngormEvent):void {
			if (!position) {
				throw new Error("RemoveDashboardCommand.execute(): You must specify the dashboard position!");
			}
			DSS.svc("dashboardService").removeDashboard(DSS.model.user.id, position).addResponder(this);
		}

		public function result(data:Object):void {
			if (this.resultHandler is Function) {
				try { this.resultHandler(data.result); } catch (err:Error) { AlertPopUp.error(err.toString(), "RemoveDashboardCommand failed in result handler.") }
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Unable to remove dashboard");
			if (this.faultHandler is Function) {
				try { this.faultHandler(info); } catch (err:Error) { AlertPopUp.error(err.toString(), "RemoveDashboardCommand failed in error handler.") }
			}
		}
	}
}