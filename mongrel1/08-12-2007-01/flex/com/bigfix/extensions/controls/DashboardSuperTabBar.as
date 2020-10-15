package com.bigfix.extensions.controls {
	import flexlib.controls.SuperTabBar;
	import flexlib.controls.tabBarClasses.SuperTab;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.Alert;
	import com.bigfix.dss.command.RemoveDashboardCommand;
	import com.bigfix.extensions.controls.events.ClosedDashboardTabEvent;

	public class DashboardSuperTabBar extends flexlib.controls.SuperTabBar {
		
		//display confirmation
		
		[Event(name="closedDashboardTab", type="com.bigfix.extensions.controls.events.ClosedDashboardTabEvent")]

		override public function onCloseTabClicked(event:Event):void {
			var index:int = getChildIndex(DisplayObject(event.currentTarget));
			Alert.show("Are you sure you want to delete this dashboard?",
						"Confirm Delete",
                     	Alert.YES| Alert.NO,
                     	null,
                     	function (event:Object):void {
						    if( event.detail == Alert.YES){
								var removeCommand:RemoveDashboardCommand = new RemoveDashboardCommand();
								removeCommand.position = index+1;	//index starts from 0, position starts from 1
								removeCommand.resultHandler = function (data:Object) :void{
									if (data.success){
										dataProvider.removeChildAt(data.dashboard_removed.position - 1);
										dispatchEvent(new ClosedDashboardTabEvent(ClosedDashboardTabEvent.TYPE_CLOSED_DASHBOARD_TAB));
									}
									else{
										Alert.show("Unable to Remove your Dashboard! - rails side");
									}
								}
								removeCommand.execute(null);
						    }
						})
		}
	}
}
