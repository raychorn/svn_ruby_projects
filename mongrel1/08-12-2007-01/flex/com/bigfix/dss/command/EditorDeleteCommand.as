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

	public class EditorDeleteCommand implements ICommand, IResponder
	{
	  private var objectClass:String;
	  private var objIDs:Array;
		private var followup:Function;
		
		public function execute(event:CairngormEvent):void {
			var edEvent:EditorEvent = event as EditorEvent
			
			objectClass = edEvent.objectClass;
			objIDs = edEvent.ids;
			followup = edEvent.followup;
			DSS.svc('EditorService').deleteMany({ 'class': objectClass, 'ids': objIDs }).addResponder(this);
		}
		
		public function result(data:Object):void {
		  var newObjs:Array = DSS.model.getObjectsByClassName(objectClass).source;
		  
		  newObjs = newObjs.filter(function (obj:IEditableObject, index:int, array:Array):Boolean { return objIDs.indexOf(obj.id) == -1; });
		  
      DSS.model.setObjectsByClassName(objectClass, new ArrayCollection(newObjs));
      
			if (followup != null)
			  followup();
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			
			Alert.show(info.message, "Failed to delete " + objectClass + "s.");
		}
	}
}