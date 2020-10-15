package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.DashboardLayout")]
	public class DashboardLayoutVO implements IValueObject {
		public var id:int;
		public var rows:int;
		public var cols:int;
		public var layout_data:Array;
		
		public function get max_widgets():int{
			var count:int = 0;
			for (var row:int=0; row < rows; row++) {
				count += layout_data[row].length;
			}
			return count;
		}
	}
}