package com.bigfix.dss.event
{
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class ChangePasswordEvent extends CairngormEvent
	{
	  public static var CHANGE_PASSWORD:String = "changePassword";
		
		public var oldPassword:String;
    public var newPassword:String;

		public function ChangePasswordEvent(oldPassword:String, newPassword:String)
		{
			super(CHANGE_PASSWORD);
			
			this.oldPassword = oldPassword;
			this.newPassword = newPassword;
		}

		override public function clone():Event {
		  return new ChangePasswordEvent(oldPassword, newPassword);
		}
	}
}
