package com.bigfix.dss.event
{
	import flash.events.Event;

	public class ShowFormEvent extends Event
	{
	  public static var SHOW_FORM_EVENT:String = "showForm";
	  
		public var editorTarget:Object;

		public function ShowFormEvent(editorTarget:Object)
		{
		  super(SHOW_FORM_EVENT);
			this.editorTarget = editorTarget;
		}
	}
}
