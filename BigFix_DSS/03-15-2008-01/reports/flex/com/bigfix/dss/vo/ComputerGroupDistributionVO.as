package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ComputerGroupDistribution")]
	public class ComputerGroupDistributionVO implements IValueObject {
		public var id:int;
		public var name:String;
		public var source_table:String;
		public var report_subject_id:int;
	}
}