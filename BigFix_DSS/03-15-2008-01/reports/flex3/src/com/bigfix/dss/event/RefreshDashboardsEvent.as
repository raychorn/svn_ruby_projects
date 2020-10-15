package com.bigfix.dss.event {
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;

	public class RefreshDashboardsEvent extends CairngormEvent
	{
		public static var EVENT_REFRESH_DASHBOARDS : String = "refreshDashboards";

		public function RefreshDashboardsEvent() {
			super( EVENT_REFRESH_DASHBOARDS );
		}

		override public function clone() : Event {
			return new RefreshDashboardsEvent();
		}
	}

}