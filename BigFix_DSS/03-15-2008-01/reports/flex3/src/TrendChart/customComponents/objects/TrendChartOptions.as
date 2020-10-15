package customComponents.objects
{
	import customComponents.objects.TransactionalObjectProxy;
	public dynamic class TrendChartOptions extends TransactionalObjectProxy {
		public function TrendChartOptions() {
			super(new TrendChartOptionsReal());
		}
	}
}

class TrendChartOptionsReal extends Object {
	public var subject_id:int = 2;
	public var metric_id:int = 2;
	public var filters:Array = new Array();
	public var computer_group_id:int = 10;
	public var startEpoch:Number = 1175798169000;
	public var endEpoch:Number = 1176402956000;
}

