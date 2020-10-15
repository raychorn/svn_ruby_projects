package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.vo.WidgetVO;
	import com.bigfix.dss.util.DSS;
	import flash.utils.*;

	public class SaveWidgetCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		public var widget:WidgetVO;

		public function execute(event:CairngormEvent):void {
			if (!widget) {
				throw new Error("SaveWidgetCommand.execute(): You must specify the widget!");
			}
			DSS.svc("widgetService").save(this.widget).addResponder(this);
		}

		public function result(data:Object):void {
			// save the new widget in our local model
			//model.widgets = new ArrayCollection(data.result);
			// notify the resultHandler
			if (this.resultHandler is Function) {
				this.resultHandler(data.result);
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Unable to Save your Widget!");
			if (this.faultHandler is Function) {
				this.faultHandler(info);
			}
		}
	}
}