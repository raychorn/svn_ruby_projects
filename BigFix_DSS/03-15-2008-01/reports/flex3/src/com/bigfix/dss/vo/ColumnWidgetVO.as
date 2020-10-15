package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import mx.collections.ArrayCollection;
	import com.bigfix.dss.vo.ComputerGroupDistributionVO;
	import com.bigfix.dss.vo.AggregateFunctionVO;
	import com.bigfix.dss.vo.PropertyVO;
	import com.bigfix.dss.vo.ColumnAnalysisVO;
	import mx.utils.ObjectUtil;
	import flash.utils.*;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ColumnWidget")]
	public class ColumnWidgetVO implements IValueObject {
		public var computer_group_distribution:ComputerGroupDistributionVO;
		public var sub_distribution_property:PropertyVO;
		public var aggregate_function:AggregateFunctionVO;
		public var computer_groups:Array;
		public var ignore_computer_group_children:Boolean;
		public var data_filters:Array;
		[Transient]
		public var options_changed:Boolean;

		public function toColumnAnalysis():ColumnAnalysisVO {
			var columnAnalysis:ColumnAnalysisVO = new ColumnAnalysisVO();
			var objDump:XML = describeType(ColumnWidgetVO);
			for each (var sourceProp:String in objDump.factory.accessor.@name) {
				if (sourceProp in columnAnalysis) {
					columnAnalysis[sourceProp] = ObjectUtil.copy(this[sourceProp]);
				}
			}
			return columnAnalysis;
		}
	}
}
