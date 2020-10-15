package com.bigfix.dss.event
{
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.bigfix.dss.vo.ComputerGroupVO;
	import com.bigfix.dss.model.ComputerGroupTree;

	public class ComputerGroupEvent extends CairngormEvent
	{
		public static var DELETE_GROUPS  : String = "deleteComputerGroups";
		
		[ArrayElementType('com.bigfix.dss.vo.ComputerGroupVO')]
		public var groups:Array;
		public var tree:ComputerGroupTree;
		public var followup:Function;

		public function ComputerGroupEvent(type:String, groups:Array,
                                       tree:ComputerGroupTree,
                                       followup:Function=null)
		{
			super(type);
			this.groups = groups;
			this.tree = tree;
			this.followup = followup;
		}

		override public function clone() : Event {
			return new ComputerGroupEvent(type, groups, tree);
		}
	}
}