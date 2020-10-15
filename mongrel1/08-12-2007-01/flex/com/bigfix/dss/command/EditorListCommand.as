package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

  import com.bigfix.dss.util.DSS;
  import com.bigfix.dss.event.EditorEvent;

	public class EditorListCommand implements ICommand, IResponder {
	  private var objectClass:String;
	  
		public function execute(event:CairngormEvent):void {
		  var edEvent:EditorEvent = event as EditorEvent;

      objectClass = edEvent.objectClass;
		  DSS.svc("EditorService").list({ 'class': objectClass }).addResponder(this);
		}

		public function result(data:Object):void {
		  DSS.model.setObjectsByClassName(objectClass, new ArrayCollection(data.result));
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Failed to retrieve " + objectClass + "s.");
		}
	}
}