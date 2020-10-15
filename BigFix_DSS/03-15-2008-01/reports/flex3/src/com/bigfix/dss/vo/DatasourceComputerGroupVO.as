package com.bigfix.dss.vo {
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.IEditableObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.DatasourceComputerGroup")]
	public class DatasourceComputerGroupVO implements IEditableObject {
		public var id : int;
		public var name:String;
		public var datasource_id:int;
		public var datasource_computer_group_id:int;

    [Transient]
    public var busy:Boolean;
		
		public function update(value:IEditableObject):void { }
		
		// junk setters
		public function set datasource(value:*):void { }
	}
}
