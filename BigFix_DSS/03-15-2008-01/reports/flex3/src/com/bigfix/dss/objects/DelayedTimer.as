package com.bigfix.dss.objects {
	import flash.utils.Timer;

	public class DelayedTimer extends Timer {
		private var _maxCount:int;
		
		public function DelayedTimer(delay:Number, repeatCount:int=0.0) {
			super(delay, repeatCount);
		}
		
		public function set maxCount(maxCount:int):void {
			this._maxCount = maxCount;
		}
		
		public function get maxCount():int {
			return this._maxCount;
		}
	}
}