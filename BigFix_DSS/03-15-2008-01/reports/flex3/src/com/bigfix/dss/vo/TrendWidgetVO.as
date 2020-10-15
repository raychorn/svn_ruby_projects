package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.ComputerGroupVO;
	import com.bigfix.dss.vo.MetricVO;
	import com.bigfix.dss.vo.TrendAnalysisVO;
	import com.bigfix.dss.util.DSS;
	import mx.utils.ObjectUtil;
	import flash.utils.*;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.TrendWidget")]
	public class TrendWidgetVO implements IValueObject {
		public var metric:MetricVO;
		public var subject:SubjectVO;
		public var computer_group:ComputerGroupVO;
		public var days:int = 7;
		public var data_filters:Array;
		public var ignore_computer_group_children:Boolean = false;
		
		public function toTrendAnalysis():TrendAnalysisVO {
			var trendAnalysis:TrendAnalysisVO = new TrendAnalysisVO();
			var objDump:XML = describeType(TrendWidgetVO);
			for each (var sourceProp:String in objDump.factory.accessor.@name) {
				if (sourceProp in trendAnalysis) {
					trendAnalysis[sourceProp] = ObjectUtil.copy(this[sourceProp]);
				}
			}
			return trendAnalysis;
		}
	}
}
