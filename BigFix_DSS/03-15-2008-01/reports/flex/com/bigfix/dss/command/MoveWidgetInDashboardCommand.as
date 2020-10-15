package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class MoveWidgetInDashboardCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		public var dashboardID:int;
		public var oldPosition:int;
		public var newPosition:int;

		public function execute(event:CairngormEvent):void {
			DSS.svc("dashboardService").moveWidget(this.dashboardID, this.oldPosition, this.newPosition).addResponder(this);
		}

		public function result(data:Object):void {
			// notify the resultHandler
			if (this.resultHandler is Function) {
				try { this.resultHandler(data.result); } catch (err:Error) { AlertPopUp.error(err.toString(), "MoveWidgetInDashboardCommand failed in result handler.") }
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Unable to Move your Widget in your Dashboard!");
			if (this.faultHandler is Function) {
				try { this.faultHandler(info); } catch (err:Error) { AlertPopUp.error(err.toString(), "MoveWidgetInDashboardCommand failed in error handler.") }
			}
		}
	}
}