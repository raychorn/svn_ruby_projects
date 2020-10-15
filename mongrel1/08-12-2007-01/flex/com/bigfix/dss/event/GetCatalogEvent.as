package com.bigfix.dss.event {
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class GetCatalogEvent extends CairngormEvent
	{
		public static var EVENT_GET_CATALOG : String = "getCatalog";

		public function GetCatalogEvent() {
			super( EVENT_GET_CATALOG );
		}

		override public function clone() : Event {
			return new GetCatalogEvent();
		}
	}

}