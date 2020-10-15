package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.PropertyOperator")]
	public class PropertyOperatorVO implements IValueObject {
		public var id:int;
		public var name:String;
		public var property_type_id:int; // Enumerated in PropertyType class.
	}
}