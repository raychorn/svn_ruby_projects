package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;
	import flash.utils.*;

	public class GetCatalogCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
		  DSS.svc("reportingCatalogService").getCatalog().addResponder(this);
		}

		public function result(data:Object):void {
			DSS.model.subjects = new ArrayCollection(data.result.subjects);
			DSS.model.property_operators = new ArrayCollection(data.result.property_operators);
			DSS.model.visualization_types = new ArrayCollection(data.result.visualization_types);
			DSS.model.computer_group_distributions = new ArrayCollection(data.result.computer_group_distributions);
			DSS.model.aggregate_functions = new ArrayCollection(data.result.aggregate_functions);
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Service Fault");
		}
	}
}