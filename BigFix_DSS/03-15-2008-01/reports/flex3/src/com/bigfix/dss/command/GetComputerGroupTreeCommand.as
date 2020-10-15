package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.event.GetComputerGroupTreeEvent;
	import com.bigfix.dss.event.RefreshComputerGroupTreeEvent;
	import com.bigfix.dss.model.ComputerGroupTree;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class GetComputerGroupTreeCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
			if ((event is GetComputerGroupTreeEvent && !DSS.model.computerGroupTree) || event is RefreshComputerGroupTreeEvent) {
			  DSS.svc("EditorService").list({ 'class': 'ComputerGroup' }).addResponder(this);
			}
		}

		public function result(data:Object):void {
			DSS.model.computerGroupTree = new ComputerGroupTree(new ArrayCollection(data.result));
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Service Fault");
		}
	}
}