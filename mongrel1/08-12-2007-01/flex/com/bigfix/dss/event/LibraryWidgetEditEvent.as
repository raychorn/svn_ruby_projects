package com.bigfix.dss.event
{
	import flash.events.Event;
	import com.bigfix.dss.vo.WidgetVO;

	public class LibraryWidgetEditEvent extends Event
	{
		public static var EVENT_LIB_WIDGET_EDIT : String = "lib_widget_edit";

		public var widget:WidgetVO;

		public function LibraryWidgetEditEvent(widget:WidgetVO)
		{
			super(EVENT_LIB_WIDGET_EDIT, true);
			this.widget = widget;
		}

		/**
		 * Override the inherited clone() method, but don't return any state.
		 */
		override public function clone() : Event
		{
			return new LibraryWidgetEditEvent(this.widget);
		}
	}
}