package com.bigfix.dss.event {
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class RefreshComputerGroupTreeEvent extends CairngormEvent {
		public static var EVENT_REFRESH_COMPUTER_GROUP_TREE:String = "refreshComputerGroupTree";

		public function RefreshComputerGroupTreeEvent() {
			super(EVENT_REFRESH_COMPUTER_GROUP_TREE);
		}

		override public function clone():Event {
			return new RefreshComputerGroupTreeEvent();
		}
	}
}