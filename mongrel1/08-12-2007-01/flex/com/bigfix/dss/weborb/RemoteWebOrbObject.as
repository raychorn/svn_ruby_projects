package com.bigfix.dss.weborb {
	import mx.rpc.remoting.mxml.RemoteObject;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.managers.PopUpManager;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	import mx.controls.Alert;
	import flash.display.DisplayObjectContainer;
	import mx.utils.ObjectUtil;
	import com.bigfix.dss.model.ModelAdapter;

	public class RemoteWebOrbObject extends RemoteObject {
		[Bindable]
		public var busyAnimatorGUIObj:Object = null;

		[Bindable]
		public var webOrbDestination:String = null;

		[Bindable]
		private var _webOrbCommand:String = null;

		[Bindable]
		public var onResultHandler:Function = null;

		[Bindable]
		public var onFaultHandler:Function = null;

		public function set webOrbCommand(webOrbCommand:String):void {
			this._webOrbCommand = webOrbCommand;
	   		this[this._webOrbCommand].addEventListener("result", this.genericResultHandler);
		}
		
		public function get webOrbCommand():String {
			return this._webOrbCommand;
		}
		
		private function genericFaultHandler(event:FaultEvent):void {
			try {
				if (this.busyAnimatorGUIObj != null) this.busyAnimatorGUIObj.currentState = 'free';
			}
			catch (err:Error) {
			}
			if (this.onFaultHandler is Function) {
				this.onFaultHandler(event);
			} else {
				var _alerter:Alert = AlertPopUp.error(event.fault.toString(), "WebOrb Communication Error");
				_alerter.styleName = "ErrorAlert";
				_alerter.width = 500;
				_alerter.height = 400;
				PopUpManager.centerPopUp(_alerter);
			}
		}

		private function genericResultHandler(event:ResultEvent):void {
			var _alerter:Alert;
			var sError:String;
			try {
				if (this.busyAnimatorGUIObj != null) this.busyAnimatorGUIObj.currentState = 'free';
			}
			catch (err:Error) {
			}
			try {
	   			if (event.result.status < 0) {
	   				sError = ObjectUtil.toString(event.result);
					_alerter = AlertPopUp.error(event.result.statusMsg + "\n" + sError, "WebOrb Service Interaction Error");
					_alerter.styleName = "ErrorAlert";
					_alerter.width = 600;
					_alerter.height = 500;
					PopUpManager.centerPopUp(_alerter);
	   			} else {
					try {
						var vo:* = event.result;
						if (this.onResultHandler is Function) this.onResultHandler(event, vo);
					} catch (err:Error) {
		   				sError = ObjectUtil.toString(event.result); //  + "\n" + sError
						_alerter = AlertPopUp.error(err.toString(), "WebOrb Service CallBack Error");
						_alerter.styleName = "ErrorAlert";
						_alerter.width = 500;
						_alerter.height = 400;
						PopUpManager.centerPopUp(_alerter);
					}
	   			}
			} catch (err:Error) {
				_alerter = AlertPopUp.error(err.toString(), "WebOrb Service Result Error");
				_alerter.styleName = "ErrorAlert";
				_alerter.width = 500;
				_alerter.height = 400;
				PopUpManager.centerPopUp(_alerter);
			}
		}
		
		public function doWebOrbServiceCall(... args):void {
			try {
				if (this.busyAnimatorGUIObj != null) this.busyAnimatorGUIObj.currentState = 'busy';
				this.operations[this._webOrbCommand].send(args);
			}
			catch (err:Error) {
			}
		}

		public function RemoteWebOrbObject(_destination:String, _commandName:String, _busyObj:DisplayObjectContainer, _onResultHandler:Function = null, _onFaultHandler:Function = null) {
			super(_destination);

			this.webOrbDestination = _destination;
			this._webOrbCommand = _commandName;
			this.busyAnimatorGUIObj = _busyObj;

			this.onResultHandler = _onResultHandler;
			this.onFaultHandler = _onFaultHandler;

	   		this.addEventListener("fault", this.genericFaultHandler);
	   		this[this._webOrbCommand].addEventListener("result", this.genericResultHandler);
		}
		
	}
}