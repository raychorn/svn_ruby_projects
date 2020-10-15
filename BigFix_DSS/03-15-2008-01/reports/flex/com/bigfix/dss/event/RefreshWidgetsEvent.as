package com.bigfix.dss.event {
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class RefreshWidgetsEvent extends CairngormEvent
	{
		public static var EVENT_REFRESH : String = "refresh";

		public function RefreshWidgetsEvent() {
			super( EVENT_REFRESH );
		}

		override public function clone() : Event {
			return new RefreshWidgetsEvent();
		}
	}

}