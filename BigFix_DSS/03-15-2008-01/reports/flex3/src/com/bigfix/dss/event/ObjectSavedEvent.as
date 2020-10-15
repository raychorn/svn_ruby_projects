package com.bigfix.dss.event
{
	import flash.events.Event;

	public class ObjectSavedEvent extends Event
	{
	  public static var OBJECT_SAVED_EVENT:String = "objectSaved";
	  
		public var savedObject:Object;

		public function ObjectSavedEvent(savedObject:Object)
		{
		  super(OBJECT_SAVED_EVENT);
			this.savedObject = savedObject;
		}
	}
}
