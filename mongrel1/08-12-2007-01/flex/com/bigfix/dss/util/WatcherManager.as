package com.bigfix.dss.util {
	import mx.binding.utils.ChangeWatcher;

	public class WatcherManager {
		private var changeWatcherInstances:Array = new Array();

		function WatcherManager() {
			super();
		}

		public function manage(newChangeWatcher:ChangeWatcher):void {
			this.changeWatcherInstances.push(newChangeWatcher);
		}

		public function removeAll():void {
			var tmpLength:int = this.changeWatcherInstances.length;
			for (var i:int = tmpLength - 1; i >= 0; i--) {
				this.changeWatcherInstances[i].unwatch();
				delete this.changeWatcherInstances[i];
			}
		}
	}
}