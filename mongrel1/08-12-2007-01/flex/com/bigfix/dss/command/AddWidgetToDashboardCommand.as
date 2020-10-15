package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;
  import com.bigfix.dss.util.DSS;
  
	public class AddWidgetToDashboardCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		public var widgetID:int;
		public var dashboardID:int;
		public var position:int = 1;

		public function execute(event:CairngormEvent):void {
			if (!widgetID || !dashboardID) {
				throw new Error("AddWidgetToDashboardCommand.execute(): You must specify the widgetID and dashboardID!");
			}
			DSS.svc("dashboardService").addWidget(this.dashboardID, this.widgetID, this.position).addResponder(this);
		}

		public function result(data:Object):void {
			// notify the resultHandler
			if (this.resultHandler is Function) {
				this.resultHandler(data.result);
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Unable to Save your Widget in your Dashboard!");
			if (this.faultHandler is Function) {
				this.faultHandler(info);
			}
		}
	}
}