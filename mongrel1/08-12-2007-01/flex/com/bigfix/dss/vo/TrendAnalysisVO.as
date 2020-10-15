package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.ComputerGroupVO;
	import com.bigfix.dss.vo.MetricVO;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.TrendAnalysis")]
	public class TrendAnalysisVO implements IValueObject {
		public var metric:MetricVO;
		public var subject:SubjectVO;
		public var computer_group:ComputerGroupVO;
		public var filterStartEpoch:Number;
		public var filterEndEpoch:Number;
		public var data_filters:Array;
		public var ignore_computer_group_children:Boolean = false;
	}
}
