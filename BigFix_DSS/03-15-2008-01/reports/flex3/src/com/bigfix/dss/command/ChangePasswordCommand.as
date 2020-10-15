package com.bigfix.dss.command
{
  import mx.controls.Alert;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;

	import com.bigfix.dss.event.ChangePasswordEvent;
	import com.bigfix.dss.util.DSS;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;

	public class ChangePasswordCommand implements ICommand
	{
		public function execute(event:CairngormEvent):void {
			var cpEvent:ChangePasswordEvent = event as ChangePasswordEvent;

			DSS.svc('userService').changePassword(cpEvent.oldPassword, cpEvent.newPassword).onResult(this.result);
		}
		
		public function result(data:Object):void {
		  var result:* = data.result;
		  
		  if (!result['success']) {
		    AlertPopUp.error(result['error'], 'Password change failed')
		  }
		}
	}
}
