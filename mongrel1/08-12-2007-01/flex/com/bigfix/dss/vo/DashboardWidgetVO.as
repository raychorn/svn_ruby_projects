package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.WidgetVO;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.DashboardWidget")]
	public class DashboardWidgetVO implements IValueObject {
		public var id:int;
		public var dashboard_id:int;
		public var dashboard_widget_id:int;
		public var widget:WidgetVO;
		public var position:int;

		public function set dashboard_widget(value:WidgetVO):void {
			widget = value;
		}
	}
}