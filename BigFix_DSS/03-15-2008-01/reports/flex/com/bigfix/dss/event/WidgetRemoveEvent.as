package com.bigfix.dss.event
{
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.bigfix.extensions.containers.Panel;
	import flash.events.Event;

	public class WidgetRemoveEvent extends Event
	{
		public static var EVENT_WIDGET_REMOVE : String = "widget_remove";

		public var widget:Panel;

		public function WidgetRemoveEvent(widget:Panel)
		{
			super(EVENT_WIDGET_REMOVE, true, false);
			this.widget = widget;
		}

		/**
		 * Override the inherited clone() method, but don't return any state.
		 */
		override public function clone() : Event
		{
			return new WidgetRemoveEvent(this.widget);
		}
	}
}