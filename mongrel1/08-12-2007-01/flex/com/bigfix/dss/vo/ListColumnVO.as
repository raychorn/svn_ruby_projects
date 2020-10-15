package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import com.bigfix.dss.vo.PropertyVO;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ListColumn")]
	public class ListColumnVO implements IValueObject {
		public var property:PropertyVO;
		public var order_direction:String; // ascending or descending
	}
}
