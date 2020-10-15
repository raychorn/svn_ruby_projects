package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.SubjectVO;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ListSubject")]
	public class ListSubjectVO implements IValueObject {
		public var subject:SubjectVO;
		public var data_filters:Array = []; // array of DataFilterVOs
		public var is_aggregate:Boolean;
	}
}
