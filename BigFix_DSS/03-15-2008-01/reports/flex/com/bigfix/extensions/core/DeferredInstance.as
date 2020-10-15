package com.bigfix.extensions.core {
	import mx.core.IDeferredInstance;

	public class DeferredInstance implements IDeferredInstance {
		private var generator:Class;
		private var opts:Object;

		public function DeferredInstance(generator:Class, opts:Object = null) {
			this.generator = generator;
			this.opts = opts;
		}

		public function getInstance():Object {
			var newInstance:* = new generator();
			if (this.opts) {
				for (var prop:String in this.opts) {
					newInstance[prop] = this.opts[prop];
				}
			}
			return newInstance;
		}
	}
}