package com.bigfix.extensions.states {
	import mx.states.State;
	import mx.states.IOverride;
	import mx.events.FlexEvent;
	import mx.core.mx_internal;
	import mx.core.UIComponent;
	import mx.states.AddChild;

	public class StateDestroy extends State {
		public function StateDestroy() {
			super();
			this.addEventListener(FlexEvent.EXIT_STATE, destroyChildren, false, 99);
		}

		private function destroyChildren(event:FlexEvent):void {
			for each (var override:IOverride in this.overrides) {
				if (override is AddChild) {
					AddChild(override).remove(UIComponent(AddChild(override).target.parent));
					AddChild(override).target = null;
					AddChild(override).mx_internal::instanceCreated = false;
				}
			}
		}

	}
}