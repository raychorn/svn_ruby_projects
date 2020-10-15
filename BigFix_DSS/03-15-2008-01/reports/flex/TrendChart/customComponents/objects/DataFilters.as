package customComponents.objects
{
	public class DataFilters extends Object {

		public var filters:Array;

		public function DataFilters() {
			super();
		}

		public function addFilter(filter:Object):void {
			filters.push(filter);
		}
	}
}