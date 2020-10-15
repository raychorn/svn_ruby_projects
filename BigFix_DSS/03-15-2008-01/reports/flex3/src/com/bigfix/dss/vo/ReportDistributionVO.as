package com.bigfix.dss.vo {
	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.ReportDistribution")]
	
	public class ReportDistributionVO {
		public var id:int;
		public var report_id:int;
		public var email_address:String;
		public var selected:int;
		
		public function toString():String {
			return "ReportDistributionVO: {" + "\nid=" + this.id.toString() + "\nreport_id=" + this.report_id.toString() + "\nemail_address=" + ((this.email_address != null) ? this.email_address.toString() : "") + "\nselected=" + ((this.selected == 1) ? "true" : "false") + "\n}";
		}
	}
}
