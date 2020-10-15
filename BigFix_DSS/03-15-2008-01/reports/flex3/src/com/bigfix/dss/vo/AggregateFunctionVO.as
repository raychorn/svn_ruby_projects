package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.AggregateFunction")]
	public class AggregateFunctionVO implements IValueObject {
		public var id:int;
		public var name:String;
		public var function_name:String;
	}
}