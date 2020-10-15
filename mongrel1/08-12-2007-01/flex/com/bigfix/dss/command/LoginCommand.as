package com.bigfix.dss.command {
	import com.adobe.cairngorm.control.CairngormEvent;
	//import com.adobe.cairngorm.commands.ICommand;
	import com.adobe.cairngorm.commands.SequenceCommand;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;

  import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.event.LoginEvent;
	import com.bigfix.dss.event.GetCatalogEvent;
	import com.bigfix.dss.event.GetComputerGroupTreeEvent;
	import com.bigfix.dss.vo.UserVO;


	public class LoginCommand extends SequenceCommand implements IResponder {
		private var testOnly:Boolean = false;

		override public function execute(event:CairngormEvent):void {
			var loginEvent:LoginEvent = LoginEvent(event);
			var service:Object = DSS.svc("userService");
			var call:Object;
			if (loginEvent.username == null) {
			  call = service.checkLogin();
			  this.testOnly = true;
			}
			else
			  call = service.login(loginEvent.username, loginEvent.password);
			  
			call.onResult(this.result).onFault(this.fault);
		}

		public function result(data:Object):void {
			if (data.result.success) {
				DSS.model.sessionID = data.result.sessionID;
				DSS.model.user = data.result.user;
        DSS.model.admin = data.result.permissions.admin;
				DSS.model.viewState = 'Main';
				this.nextEvent = new GetCatalogEvent();
				this.executeNextCommand();
				new GetComputerGroupTreeEvent().dispatch();
			} else {
			  if (this.testOnly)
			    DSS.model.viewState = 'Login'
			  else
				  Alert.show("Login Failed!");
			}
		}

		public function fault(info:Object):void {
			var faultEvent:FaultEvent = FaultEvent(info);
			Alert.show(info.message, "Service Fault");
		}
	}
}