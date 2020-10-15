package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.VisualizationType")]
	public class VisualizationTypeVO implements IValueObject {
		public var id:int;
		public var name:String;
	}
}