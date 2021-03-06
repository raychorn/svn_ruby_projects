package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;

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
				this.resultHandler(data.result);
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Unable to Move your Widget in your Dashboard!");
			if (this.faultHandler is Function) {
				this.faultHandler(info);
			}
		}
	}
}