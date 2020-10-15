package com.bigfix.dss.command
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;

	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.event.ComputerGroupEvent;
	import com.bigfix.dss.vo.ComputerGroupVO;
	import com.bigfix.dss.model.ComputerGroupTree;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class DeleteComputerGroupsCommand implements ICommand, IResponder
	{
		private var groups:Array;
		private var tree:ComputerGroupTree;
		private var followup:Function;
		
		public function execute(event:CairngormEvent):void {
			var cgEvent:ComputerGroupEvent = ComputerGroupEvent(event);
			var objIDs:Array;

			groups = cgEvent.groups;
			tree = cgEvent.tree;
			followup = cgEvent.followup;
			
			objIDs = groups.map(function(group:ComputerGroupVO, idx:int, ary:Array):int { return group.id; });
			DSS.svc('EditorService').deleteMany({ 'class': 'ComputerGroup', 'ids': objIDs }).addResponder(this);
		}
		
		public function result(data:Object):void {
      for each (var group:ComputerGroupVO in groups) {
        tree.remove(group);
      }

      if (followup != null)
        followup(groups);
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Failed to delete computer group(s)");
		}
	}
}