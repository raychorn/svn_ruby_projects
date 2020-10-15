package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;

	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class RemoveWidgetFromDashboardCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		public var dashboardID:int;
		public var position:int = -1;

		public function execute(event:CairngormEvent):void {
			if (position == -1 || !dashboardID) {
				throw new Error("RemoveWidgetFromDashboardCommand.execute(): You must specify the position and dashboardID!");
			}
			DSS.svc("dashboardService").removeWidget(this.dashboardID, this.position).addResponder(this);
		}

		public function result(data:Object):void {
			// notify the resultHandler
			if (this.resultHandler is Function) {
				try { this.resultHandler(data.result); } catch (err:Error) { AlertPopUp.error(err.toString(), "RemoveWidgetFromDashboardCommand failed in result handler.") }
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Unable to save your dashboard!");
			if (this.faultHandler is Function) {
				try { this.faultHandler(info); } catch (err:Error) { AlertPopUp.error(err.toString(), "RemoveWidgetFromDashboardCommand failed in error handler.") }
			}
		}
	}
}