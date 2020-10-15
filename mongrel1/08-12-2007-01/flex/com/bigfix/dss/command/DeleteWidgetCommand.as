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

	public class DeleteWidgetCommand implements ICommand, IResponder {
		public var resultHandler:Function;
		public var faultHandler:Function;
		public var widget:WidgetVO;

		public function execute(event:CairngormEvent):void {
			if (!widget) {
				throw new Error("DeleteWidgetCommand.execute(): You must specify the widget!");
			}
			DSS.svc('widgetService').destroy(this.widget).addResponder(this);
		}
		
		public function result(data:Object):void {
			if (this.resultHandler is Function) {
				this.resultHandler(data.result);
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Unable to delete your widget!");
			if (this.faultHandler is Function) {
				this.faultHandler(info);
			}
		}
	}
}