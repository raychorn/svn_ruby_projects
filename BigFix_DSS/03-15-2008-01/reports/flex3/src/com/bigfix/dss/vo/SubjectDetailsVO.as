package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.SubjectDetails")]
	public class SubjectDetailsVO implements IValueObject {
		public var id:int;
		public var className:String;
	}
}