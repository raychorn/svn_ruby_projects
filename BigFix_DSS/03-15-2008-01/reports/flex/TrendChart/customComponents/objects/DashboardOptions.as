package customComponents.objects
{
	import customComponents.objects.TransactionalObjectProxy;
	public dynamic class DashboardOptions extends TransactionalObjectProxy {
		public function DashboardOptions() {
			super(new DashboardOptionsReal());
		}
	}
}

class DashboardOptionsReal extends Object {
	public var subject_id:int = 2;
	public var metric_id:int = 2;
	public var computer_group_id:int = 1;
	public var max_computer_group_depth:int = 1;
	public var trend_days:int = 365;
	public var change_days:int = 1;
}


