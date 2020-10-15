package com.bigfix.dss.event
{
	import flash.events.Event;
	import com.adobe.cairngorm.control.CairngormEvent;
	import com.bigfix.dss.vo.IEditableObject;

	public class EditorEvent extends CairngormEvent
	{
	  public static var EDITOR_LIST    : String = "editorList";
		public static var EDITOR_CREATE  : String = "editorCreate";
		public static var EDITOR_UPDATE  : String = "editorUpdate";
		public static var EDITOR_DELETE  : String = "editorDelete";
		
		public var objectClass:String;
		public var obj:IEditableObject;
		[ArrayElementType(int)]
		public var ids:Array;
		public var arg:*;
		public var followup:Function;

		public function EditorEvent(type:String, objectClass:String, subject:*=null, arg:*=null)
		{
			super(type);
			this.objectClass = objectClass;
			if (subject == null)
			  ;
			else if (subject is IEditableObject)
			  this.obj = subject;
			else if (subject is Array)
			  this.ids = subject;
			else
			  throw "Second argument to EditorEvent constructor must be an IEditableObject or an Array of IDs."
			
			this.arg = arg;
		}

		override public function clone() : Event {
			return new EditorEvent(type, objectClass, obj != null ? obj : ids, arg);
		}
	}
}
