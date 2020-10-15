package com.bigfix.dss.rest {
	import mx.rpc.http.mxml.HTTPService;
	import mx.rpc.events.*;
	import mx.controls.Alert;
	import com.bigfix.dss.rest.ObjectExplainer;
	import mx.collections.ArrayCollection;
	import mx.utils.ArrayUtil;
	import com.bigfix.dss.view.general.Alert.AlertPopUp;
	
	public class httpService {
		public var srvc:HTTPService = new HTTPService;
		public var requestObj:Object = new Object;

		public var isDebugMode:Boolean = false;

		public var isRunningLocal:Boolean = true;
		
		public var userID:String = "";

		public const arrayResultType:String = "array";

		public const DEBUG_MODE_ON:Boolean = true;
		public const DEBUG_MODE_OFF:Boolean = false;
		
		public const RUNNING_LOCAL:Boolean = true;
		public const RUNNING_REMOTE:Boolean = false;

		public var alertShowFunc:Function;

		public var faultCallBack:Function;

		private var callback:Function;
		
		private var queue:Array = new Array;
		
		private var isBusy:Boolean = false;

		public function makeIntoArrayCollection(obj:*):ArrayCollection {
			var ar:Array = new Array;
			if (obj != null) {
				if (obj is Array) {
					ar = obj;
				} else if (obj is ArrayCollection) {
					ar = obj.source;
				} else {
					ar = mx.utils.ArrayUtil.toArray(obj);
				}
			}
			return new ArrayCollection(ar);
		}
		
		public function makeEventResultIntoArrayCollection(event:ResultEvent):ArrayCollection {
			return makeIntoArrayCollection(event.result.source);
		}
		
		public function htmlForAspConversion(inStr:String = ""):String {
			var patLT:RegExp = /\</g;
			var patGT:RegExp = /\>/g;
			return inStr.replace(patLT,"&lt;").replace(patGT,"&gt;");
		}
		
		private function myCallback(event:ResultEvent):void {
			this.callback(event);
			if (this.queue.length > 0) {
				var o:Object = this.queue.pop();
				this.requestObj = o.request;
				return this.invokeHTTPService(o.url, o.callback, o.resultFormat);
			} else {
				this.isBusy = false;
			}
		}

		public function isFaultInConfigXML(event:FaultEvent):Boolean {
			return ( (event.fault.faultString.indexOf("XML parser failure") > -1) && (this.srvc.url.indexOf("config.xml") > -1) );
		}
			
		public function onFaultHandler(event:FaultEvent):void {
			var ex:ObjectExplainer = new ObjectExplainer(this.requestObj);
			var sEX:String = ex.explainThisWay("\n");
			var title:String = "Generic REST/RPC Fault";
			var msg:String = "";
			if (this.isFaultInConfigXML(event)) {
				msg = "There is an XML Syntax Error associated with " + this.srvc.url + ".";
				if (this.alertShowFunc is Function) {
					try { this.alertShowFunc(msg, title); } catch (err:Error) { AlertPopUp.error(err.toString(), "httpService::onFaultHandler failed in alertShowFunc handler (1).") }
				} else {
					AlertPopUp.error(msg, title);
				}
			} else {
				msg = event.fault.faultString + "\n" + event.fault.message + "\n" + "isRunningLocal=" + isRunningLocal + "\n" + "this.srvc.url=" + this.srvc.url + "\n" + ((this.srvc.request != null) ? "cmd=" + this.srvc.request.cmd + "\n" : "") + sEX;
				if (this.alertShowFunc is Function) {
					try { this.alertShowFunc(msg, title); } catch (err:Error) { AlertPopUp.error(err.toString(), "httpService::onFaultHandler failed in alertShowFunc handler (2).") }
				} else {
					AlertPopUp.error(msg, title);
				}
			}
		}
		
		private function myFaultCallback(event:FaultEvent):void {
			if (this.faultCallBack is Function) {
				try { this.faultCallBack(event); } catch (err:Error) { AlertPopUp.error(err.toString(), "httpService::myFaultCallback failed in faultCallBack handler.") }
			} else {
				this.onFaultHandler(event);
			}
		}
		
		public function httpService(_isDebugMode:Boolean = this.DEBUG_MODE_OFF, _isRunningLocal:Boolean = this.RUNNING_LOCAL):void {
			this.isDebugMode = _isDebugMode;
			this.isRunningLocal = _isRunningLocal;
			this.srvc.addEventListener(ResultEvent.RESULT, this.myCallback);
			this.srvc.addEventListener("fault", this.myFaultCallback);
		}
		
		private function invokeHTTPService(url:String, callback:Function, resultFormat:String = this.arrayResultType):void {
			var title:String = "";
			var msg:String = "";
			this.srvc.showBusyCursor = true;
			this.srvc.url = url;
			this.srvc.useProxy = false;
			this.srvc.resultFormat = resultFormat;
			this.srvc.method = "POST";
			this.callback = callback;
			this.srvc.concurrency = "single";
			this.srvc.makeObjectsBindable = true;
			this.srvc.request = this.requestObj;
			if (this.requestObj != null) {
				if (this.isDebugMode) {
					this.srvc.request.debugMode = "1";
				}
				if (this.isRunningLocal) {
					this.srvc.request.runningLocal = "1";
				}
				this.srvc.request.userid = this.userID;
			}
			try {
				this.srvc.send();
			} catch (err:Error) {
				title = "Error :: invokeHTTPService()";
				msg = err.toString();
				if (this.alertShowFunc is Function) {
					try { this.alertShowFunc(msg, title); } catch (err:Error) { AlertPopUp.error(err.toString(), "httpService::invokeHTTPService failed in alertShowFunc handler.") }
				} else {
					AlertPopUp.error(msg, title);
				}
			}
		}

		public function send(url:String, callback:Function, resultFormat:String = this.arrayResultType):void {
			if (this.isBusy == false) {
				this.isBusy = true;
				this.invokeHTTPService(url, callback, resultFormat);
			} else {
				var o:Object = new Object;
				o.url = url;
				o.callback = callback;
				o.resultFormat = resultFormat;
				o.request = this.requestObj;
				this.queue.push(o);
			}
		}
		
		public function deepCopyQueue():Array {
			return com.bigfix.dss.rest.ArrayUtils.deepCopyFrom(this.queue);
		}
		
		public function useQueue(aQueue:Array):void {
			this.queue = aQueue;
		}
	}
}