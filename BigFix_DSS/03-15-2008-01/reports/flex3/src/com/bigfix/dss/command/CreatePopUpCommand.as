package com.bigfix.dss.command {
	import mx.managers.PopUpManager;
	import mx.core.IFlexDisplayObject;
	import mx.core.Application;
	import flash.display.DisplayObject;

	import com.adobe.cairngorm.control.CairngormEvent;
	import com.adobe.cairngorm.commands.ICommand;

	import com.bigfix.dss.event.CreatePopUpEvent;

	public class CreatePopUpCommand implements ICommand {
		public function execute(event:CairngormEvent):void {
			var createPopUpEvent:CreatePopUpEvent = CreatePopUpEvent(event);
			var popUp:IFlexDisplayObject = PopUpManager.createPopUp(DisplayObject(Application.application), createPopUpEvent.className, createPopUpEvent.modal);
			popUp.width = createPopUpEvent.width;
			popUp.height = createPopUpEvent.height;
			PopUpManager.centerPopUp(popUp);
		}
	}
}