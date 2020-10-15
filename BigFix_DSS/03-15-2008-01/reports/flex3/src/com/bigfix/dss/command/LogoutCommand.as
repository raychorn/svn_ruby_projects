package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;

	import com.bigfix.dss.event.LogoutEvent;
	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.vo.UserVO;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class LogoutCommand implements ICommand, IResponder {
		public function execute(event:CairngormEvent):void {
			var logoutEvent:LogoutEvent = LogoutEvent(event);
			
			DSS.svc("userService").logoutDSS(logoutEvent.sessionID).addResponder(this);
		}

		public function result(data:Object):void {
			DSS.model.sessionID = null;
			DSS.model.viewState = 'Logout';
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			AlertPopUp.error(info.message, "Service Fault");
		}
	}
}