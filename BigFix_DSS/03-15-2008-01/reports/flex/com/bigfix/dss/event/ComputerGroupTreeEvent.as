package com.bigfix.dss.event
{
  import com.bigfix.dss.vo.ComputerGroupVO;
	import flash.events.Event;

	public class ComputerGroupTreeEvent extends Event
	{
	  public static var TREE_REPARENT_GROUP:String = "treeReparentGroup";
	  
		public var group:ComputerGroupVO;
		public var oldParent:ComputerGroupVO;
		public var parent:ComputerGroupVO;

		public function ComputerGroupTreeEvent(type:String, group:ComputerGroupVO,
		                                       oldParent:ComputerGroupVO,
		                                       parent:ComputerGroupVO)
		{
		  super(type);
		  this.group = group;
		  this.oldParent = oldParent;
		  this.parent = parent;
		}
		
		override public function clone(): Event
		{
		  return new ComputerGroupTreeEvent(type, group, oldParent, parent);
		}
	}
}
