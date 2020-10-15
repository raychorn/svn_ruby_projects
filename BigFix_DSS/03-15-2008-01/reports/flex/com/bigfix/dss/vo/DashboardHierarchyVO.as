package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.DashboardLayoutVO;
	import com.bigfix.dss.view.dashboard.Dashboard;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.DashboardHierarchy")]
	public class DashboardHierarchyVO implements IValueObject {
		public var id:int;
		public var folder_id:int;
		public var parent_id:int;
	}
}