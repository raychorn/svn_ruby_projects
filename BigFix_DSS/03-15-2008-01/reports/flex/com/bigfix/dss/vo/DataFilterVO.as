package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import com.bigfix.dss.vo.PropertyVO;
	import com.bigfix.dss.vo.PropertyOperatorVO;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.DataFilter")]
	public class DataFilterVO implements IValueObject {
		public var property:PropertyVO;
		public var property_operator:PropertyOperatorVO;
		public var value:String;
	}
}