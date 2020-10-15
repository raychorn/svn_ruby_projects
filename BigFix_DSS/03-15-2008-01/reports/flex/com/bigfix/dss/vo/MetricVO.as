package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Metric")]
	public class MetricVO implements IValueObject {
		public var id:int;
		public var name:String;
	}
}