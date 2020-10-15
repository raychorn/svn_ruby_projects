package com.bigfix.dss.vo
{
	import com.bigfix.dss.vo.IEditableObject

import mx.rpc.remoting.mxml.RemoteObject;
import com.bigfix.dss.weborb.RemoteWebOrbObject;
import com.bigfix.dss.command.GetReportsCommand;
import flash.display.DisplayObjectContainer;
	[Bindable]
	[RemoteClass(alias="com.bigfix.dss.vo.Report")]
	
	public class ReportVO implements IEditableObject {
		public var id:int;
		public var name:String;
		public var next_scheduled_run:Date;
		public var user_id:int;
		public var data:Array;
		
		[Transient]
		public var busy:Boolean;
		
		public function update(newObj:IEditableObject):void {
		  var newReport:ReportVO = newObj as ReportVO;
		  
		  this.id = newReport.id;
		  this.name = newReport.name;
		  this.next_scheduled_run = newReport.next_scheduled_run;
		  this.user_id = newReport.user_id;
		  this.data = newReport.data;
		}
		
		public function removeSelf(busy:DisplayObjectContainer, onResultWebOrb:Function, onFaultWebOrb:Function):void {
			var _weborbObj:RemoteWebOrbObject;
			_weborbObj = new RemoteWebOrbObject("ReportWriter", "deleteReport", busy, onResultWebOrb, onFaultWebOrb);
			var svc:RemoteObject = GetReportsCommand.svc.svc;
			_weborbObj.endpoint = svc.channelSet.currentChannel.endpoint;
			_weborbObj.doWebOrbServiceCall(this);
		}
		
		public function toString():String {
			return "ReportVO: {" + "\nid=" + ((this.id > 0) ? this.id.toString() : "") + "\nname=" + ((this.name != null) ? this.name.toString() : "") + "\nnext_scheduled_run=" + ((this.next_scheduled_run != null) ? this.next_scheduled_run.toString() : "") + "\n}";
		}
	}
}
