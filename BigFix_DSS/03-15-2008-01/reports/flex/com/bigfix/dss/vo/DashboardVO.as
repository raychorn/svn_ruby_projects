package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.DashboardLayoutVO;
	import com.bigfix.dss.view.dashboard.Dashboard;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Dashboard")]
	public class DashboardVO implements IValueObject {
		public var id:int;
		public var name:String;
		public var user_id:int;
		public var position:int;
		public var dashboard_layout_id:int;
		
		public var dashboard_layout:DashboardLayoutVO;
		
		[Transient]
		public var parent:Dashboard;
		
		[ArrayElementType("com.bigfix.dss.vo.DashboardWidgetVO")]
		[Transient]
		public var dashboard_widgets:ArrayCollection;

		public function set dashboard_dashboard_widgets(value:Array):void {
			dashboard_widgets = new ArrayCollection(value);
		}
	}
}