package com.bigfix.dss.command
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.collections.ArrayCollection;

	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.event.EditorEvent;
	import com.bigfix.dss.vo.IEditableObject;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class EditorCreateCommand implements ICommand, IResponder
	{
	  private var objectClass:String;
	  private var obj:IEditableObject;
		private var followup:Function;
		
		public function execute(event:CairngormEvent):void {
			var edEvent:EditorEvent = event as EditorEvent
			var attrs:* = edEvent.arg;
			
			objectClass = edEvent.objectClass;
			obj = edEvent.obj;
			followup = edEvent.followup;
			DSS.svc('EditorService').create(obj, attrs).addResponder(this);
		}
		
		public function result(data:Object):void {
			var newObj:IEditableObject = data.result as IEditableObject;

      try {
        DSS.model.getObjectsByClassName(objectClass).addItem(newObj);
      }
      catch (err:Error) {
        obj.update(newObj);
      }
      
      obj.busy = false;
			if (followup != null)
			  followup(newObj);
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);

			obj.busy = false;
			AlertPopUp.error(info.message, "Failed to create " + objectClass + ".");
		}
	}
}