package com.bigfix.dss.vo
{
	import com.bigfix.dss.vo.IEditableObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.User")]
	public class UserVO implements IEditableObject {
		public var id:int;
		public var name:String;
		public var email:String;
		public var username:String;
		public var password:String;
		public var password_confirmation:String;
		
		[ArrayElementType("int")]
    public var role_ids:Array;
    
    [Transient]
    public var busy:Boolean;
    
    [Transient]
    [ArrayElementType("com.bigfix.dss.vo.RoleVO")]
    public var roles:Array;

    public function update(newObj:IEditableObject):void
    {
      var newUser:UserVO = newObj as UserVO;
      
      id = newUser.id;
      name = newUser.name;
      email = newUser.email;
      username = newUser.username;
    }

		// junk setters
		public function set hashed_password(value:String):void { }
		public function set remember_token_expires_at(value:String):void { }
		public function set remember_token(value:String):void { }
		public function set salt(value:String):void { }
	}
}