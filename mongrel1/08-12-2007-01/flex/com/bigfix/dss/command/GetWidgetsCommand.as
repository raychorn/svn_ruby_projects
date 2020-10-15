package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;
	import flash.utils.*;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class GetWidgetsCommand implements ICommand, IResponder {
		private var _callback:Function;
		private var _args:Array;

		public function execute(event:CairngormEvent):void {
			DSS.svc("widgetService").getLibrary(DSS.model.user).addResponder(this);
		}

		public function _execute(event:CairngormEvent, callback:Function = null, ... args):void {
			this._callback = callback;
			this._args = args;
			this.execute(event);
		}

		public function result(data:Object):void {
			DSS.model.widgets = new ArrayCollection(data.result);
			DSS.model.currentSearchText = null;
			if (this._callback != null) {
				try { this._callback(this._args); } 
					catch (err:Error) { 
						AlertPopUp.error(err.toString(), "ERROR from GetWidgetsCommand Result Callback.");
					}
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Service Fault");
		}
	}
}