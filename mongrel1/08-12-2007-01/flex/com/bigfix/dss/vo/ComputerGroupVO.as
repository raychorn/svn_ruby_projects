package com.bigfix.dss.vo {
	import mx.collections.ArrayCollection;
	import mx.skins.ProgrammaticSkin; // XXX: hack (see below)
	import com.bigfix.dss.vo.IEditableObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ComputerGroup")]
	public class ComputerGroupVO implements IEditableObject {
		public var id : int;
		public var name:String;
		public var filter:Array;
		public var parent_id:int;

		[Transient]
		public var legendMarker:ProgrammaticSkin; // XXX: hack for storing legend markers
		
		[Transient]
		public var vintage:Date;
		
		[Transient]
		[ArrayElementType("com.bigfix.dss.vo.ComputerGroupVO")]
		public var children:ArrayCollection;
		
		[Transient]
		public var busy:Boolean;

    public function update(newObj:IEditableObject):void
    {
      var newGroup:ComputerGroupVO = newObj as ComputerGroupVO;
      
      id = newGroup.id;
      name = newGroup.name;
      filter = newGroup.filter;
      parent_id = newGroup.parent_id;
    }

		// junk setters
		public function set parent(value:ComputerGroupVO):void { }
		public function set roles(value:Array):void { }
	}
}
