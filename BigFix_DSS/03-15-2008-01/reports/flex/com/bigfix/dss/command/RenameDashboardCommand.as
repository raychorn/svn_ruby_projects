package com.bigfix.dss.command {
	//not all of the imports might be needed
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class RenameDashboardCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		
		public var position:int;
		public var new_name:String;

		public function execute(event:CairngormEvent):void {
		  DSS.svc("dashboardService").renameDashboard(DSS.model.user.id, position, new_name).addResponder(this);
		}

		public function result(data:Object):void {
			if (this.resultHandler is Function) {
				try { this.resultHandler(data.result); } catch (err:Error) { AlertPopUp.error(err.toString(), "RenameDashboardCommand failed in result handler.") }
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Unable to rename dashboard");
			if (this.faultHandler is Function) {
				try { this.faultHandler(info); } catch (err:Error) { AlertPopUp.error(err.toString(), "RenameDashboardCommand failed in error handler.") }
			}
		}
	}
}