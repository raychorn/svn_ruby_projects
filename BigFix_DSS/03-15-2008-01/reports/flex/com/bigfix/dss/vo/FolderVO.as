package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.DashboardLayoutVO;
	import com.bigfix.dss.view.dashboard.Dashboard;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Folder")]
	public class FolderVO implements IValueObject {
		public var id:int;
		public var name:String;
		public var user_id:int;
	}
}