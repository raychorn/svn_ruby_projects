package com.bigfix.dss.vo {
	import mx.collections.ArrayCollection;

	import com.adobe.cairngorm.vo.IValueObject;
	import com.bigfix.dss.vo.ListSubjectVO;
	import com.bigfix.dss.vo.PropertyVO;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ListAnalysis")]
	public class ListAnalysisVO implements IValueObject {
		public var list_subjects:Array;
		public var list_columns:Array;
		public var user_temp_table_id:int;
		public var sort_columns:Array;
	}
}
