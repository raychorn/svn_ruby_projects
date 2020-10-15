package customComponents.objects
{
	//import customComponents.objects.DataFilters;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Bindable]
	public class ComputerListOptions extends Object {
		private var _eventDispatcher:EventDispatcher;

		public static const GROUPING_TYPE_DISTINCT_ALL:int = 1;
		public static const GROUPING_TYPE_DISTINCT_COMPUTER:int = 2;
		public static const GROUPING_TYPE_DISTINCT_SUBJECT:int = 3;

		private var _grouping_type:int = GROUPING_TYPE_DISTINCT_ALL;
		private var _computer_group_id:int;
		public var subject_id:int;
		public var included_columns:Array = new Array();
		public var order_by:String = "";
		//public var dataFilters:DataFilters;

		public function ComputerListOptions() {
			_eventDispatcher = new EventDispatcher();
			super();
		}

		public function set grouping_type(value:int):void {
			if (value != GROUPING_TYPE_DISTINCT_ALL || value != GROUPING_TYPE_DISTINCT_COMPUTER || value != GROUPING_TYPE_DISTINCT_SUBJECT) {
				throw new Error("you specified an invalid grouping type");
			}
			_grouping_type = value;
		}

		public function get grouping_type():int {
			return _grouping_type;
		}

		public function set computer_group_id(value:int):void {
			_computer_group_id = value;
		}

		public function get computer_group_id():int {
			return _computer_group_id;
		}
	}
}
