package com.bigfix.dss.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;

	public class LoginEvent extends CairngormEvent
	{
		public static var EVENT_LOGIN : String = "login";

		public var username : String;

		public var password : String;

		public function LoginEvent(u:String, p:String)
		{
			super(EVENT_LOGIN);
			this.username = u;
			this.password = p;
		}

		/**
		 * Override the inherited clone() method, but don't return any state.
		 */
		override public function clone() : Event
		{
			return new LoginEvent(this.username, this.password);
		}

	}

}