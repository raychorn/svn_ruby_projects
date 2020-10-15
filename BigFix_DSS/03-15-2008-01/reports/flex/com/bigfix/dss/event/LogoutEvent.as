package com.bigfix.dss.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;

	public class LogoutEvent extends CairngormEvent
	{
		public static var EVENT_LOGOUT : String = "logout";

		public var sessionID:String;

		public function LogoutEvent(sessionID:String)
		{
			super(EVENT_LOGOUT);
			this.sessionID = sessionID;
		}

		/**
		 * Override the inherited clone() method, but don't return any state.
		 */
		override public function clone() : Event
		{
			return new LogoutEvent(this.sessionID);
		}

	}

}