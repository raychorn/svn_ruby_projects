package com.bigfix.dss.vo
{
	

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Role")]
	public class RoleVO implements IEditableObject {
		public var id:int;
		public var name:String;
		public var admin:Boolean;
		public var role_id:int;
		public var user_id:int;
		
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
