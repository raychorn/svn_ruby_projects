package com.bigfix.dss.model {
	import com.bigfix.dss.vo.WebOrbResultVO;
	
	public class ModelAdapter {
		public static var const_WebOrbResult_type:String = "WebOrbResult";
		
		private var _result:*;
		private var _vo:*;
		
		private function transformModel(result:*):* {
			var retVal:*;
			switch (result.type) {
				case const_WebOrbResult_type:
					retVal = new WebOrbResultVO();
				break;
			}
			return retVal;
		}
		
		public function set result(result:*):void {
			this._result = result;
			this._vo = this.transformModel(this._result);
		}
		
		public function get result():* {
			return this._result;
		}
		
		public function get vo():* {
			return this._vo;
		}
		
		private function adaptModel(from:*, to:*):void {
			var o:*;
			for (o in result) {
				try { to[o] = from[o]; } catch (err:Error) { }
			}
		}
		
		public function ModelAdapter(result:*):void {
			this.result = result;
		}
	}
}