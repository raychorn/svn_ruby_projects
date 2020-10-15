package com.bigfix.dss.event
{
	import flash.events.Event;

	public class LibraryWidgetRemoveEvent extends Event
	{
		public static var EVENT_LIB_WIDGET_REMOVE : String = "lib_widget_remove";

		public var widget_id:int;

		public function LibraryWidgetRemoveEvent(widget_id:int)
		{
			super(EVENT_LIB_WIDGET_REMOVE, true);
			this.widget_id = widget_id;
		}

		/**
		 * Override the inherited clone() method, but don't return any state.
		 */
		override public function clone() : Event
		{
			return new LibraryWidgetRemoveEvent(this.widget_id);
		}
	}
}