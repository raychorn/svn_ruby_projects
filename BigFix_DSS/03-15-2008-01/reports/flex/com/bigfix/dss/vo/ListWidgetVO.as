package com.bigfix.dss.vo {
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	import flash.utils.*;
	
	import com.adobe.cairngorm.vo.IValueObject;
	import com.bigfix.dss.vo.ListSubjectVO;
	import com.bigfix.dss.vo.PropertyVO;
	import com.bigfix.dss.vo.ListAnalysisVO;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ListWidget")]
	public class ListWidgetVO implements IValueObject {
		public var list_subjects:Array;
		public var row_limit:int;
		public var list_columns:Array;
		public var user_temp_table_id:int;
		public var sort_columns:Array;

		public function toListAnalysis():ListAnalysisVO {
			var listAnalysis:ListAnalysisVO = new ListAnalysisVO();
			var objDump:XML = describeType(ListWidgetVO);
			for each (var sourceProp:String in objDump.factory.accessor.@name) {
				if (sourceProp in listAnalysis) {
					listAnalysis[sourceProp] = ObjectUtil.copy(this[sourceProp]);
				}
			}
			listAnalysis.user_temp_table_id = undefined;
			return listAnalysis;
		}
	}
}
