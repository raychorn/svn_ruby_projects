package com.bigfix.dss.event {
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetComputerGroupTreeEvent extends CairngormEvent {
		public static var EVENT_GET_COMPUTER_GROUP_TREE:String = "getComputerGroupTree";

		public function GetComputerGroupTreeEvent() {
			super(EVENT_GET_COMPUTER_GROUP_TREE);
		}

		override public function clone():Event {
			return new GetComputerGroupTreeEvent();
		}
	}
}