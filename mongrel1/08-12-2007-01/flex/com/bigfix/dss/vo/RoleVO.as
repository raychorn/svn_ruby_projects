package com.bigfix.dss.vo
{
	import com.bigfix.dss.vo.IEditableObject

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Role")]
	public class RoleVO implements IEditableObject {
		public var id:int;
		public var name:String;
		public var admin:Boolean;
		
		[Transient]
		public var busy:Boolean;

    public function update(newObj:IEditableObject):void
    {
      var newRole:RoleVO = newObj as RoleVO;
      
      id = newRole.id;
      name = newRole.name;
      admin = newRole.admin;
    }
	}
}
