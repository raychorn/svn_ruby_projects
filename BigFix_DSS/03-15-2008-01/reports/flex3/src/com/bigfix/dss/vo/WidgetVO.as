package com.bigfix.dss.vo {
	import com.adobe.cairngorm.vo.IValueObject;
	import com.bigfix.dss.vo.VisualizationTypeVO;
	import com.bigfix.dss.vo.TrendWidgetVO;
	import com.bigfix.dss.vo.ListWidgetVO;
	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.model.Constants;

	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Widget")]
	public class WidgetVO implements IValueObject {
		public var id:int;
		public var user_id:int;
		public var name:String;
		public var description:String;

		public var visualization_type_id:int;
		public var visualization_type:VisualizationTypeVO;

		public var user:UserVO;
		
		public var visualization_type_options:*;

		
		public function get user_name():String{
			return user.name;
		}
		public function get visualization_type_name():String{
			return visualization_type.name;
		}
		/*
		// the setter here for visualization_type is for when we create a widget instance from Flex
		private var _visualization_type:VisualizationTypeVO;
		public function set visualization_type(value:VisualizationTypeVO):void {
			_visualization_type = value;
			visualization_type_id = _visualization_type.id; // this should fire off the setter which gives 'visualiazation_type_options' a real Class
		}
		public function get visualization_type():VisualizationTypeVO {
			return _visualization_type;
		}

		// the setter here for visualization_type_id is for when we load a Widget instance from Rails
		private var _visualization_type_id:int;
		public function set visualization_type_id(value:int):void {
			_visualization_type_id = value;
			var matchingVisualizationTypeArr:Array = DSS.model.visualization_types.source.filter(function (item:*, index:int, array:Array):Boolean {
				return (item.id == _visualization_type_id);
			}, null);
			if (!matchingVisualizationTypeArr.length) {
				throw new Error("WidgetVO: unable to find a matching visualization type for id: ", _visualization_type_id);
			}
			_visualization_type = matchingVisualizationTypeArr[0];
			switch (_visualization_type_id) {
				case Constants.VISUALIZATION_TYPE_LINE:
					if (visualization_type_options == undefined) {
						visualization_type_options = new TrendWidgetVO();
					} else {
						visualization_type_options = TrendWidgetVO(visualization_type_options);
					}
					break;
				case Constants.VISUALIZATION_TYPE_LIST:
					if (visualization_type_options == undefined) {
						visualization_type_options = new ListWidgetVO();
					} else {
						visualization_type_options = ListWidgetVO(visualization_type_options);
					}
					break;
				case Constants.VISUALIZATION_TYPE_PIE:
					trace("WidgetVO setting pie stuff!");
					break;
			}
		}

		public function get visualization_type_id():int {
			return _visualization_type_id;
		}
		*/
	}
}