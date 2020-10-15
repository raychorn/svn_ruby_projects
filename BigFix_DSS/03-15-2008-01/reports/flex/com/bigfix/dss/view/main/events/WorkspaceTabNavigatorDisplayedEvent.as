package com.bigfix.dss.view.main.events {
  import flash.events.Event;

	public class WorkspaceTabNavigatorDisplayedEvent extends Event {
	
		public function WorkspaceTabNavigatorDisplayedEvent(type:String) {
			super(type);
		}
		
		public static var type_WORKSPACE_TABNAVIGATOR_DISPLAYED:String = "workspaceTabNavigatorDisplayed";
		  
		override public function clone(): Event {
		  return new WorkspaceTabNavigatorDisplayedEvent(type);
		}
	}
}
