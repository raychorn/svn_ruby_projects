package com.bigfix.dss.event {
	import com.adobe.cairngorm.control.CairngormEvent;
	import flash.events.Event;

	public class CreatePopUpEvent extends CairngormEvent {
		public static var EVENT_CREATE_POPUP : String = "createPopUp";

		public var className:Class;
		public var modal:Boolean;
		public var width:int;
		public var height:int;

		public function CreatePopUpEvent(className:Class, modal:Boolean = true, width:int = 500, height:int = 500) {
			super(EVENT_CREATE_POPUP);
			this.className = className;
			this.modal = modal;
			this.width = width;
			this.height = height;
		}

		override public function clone() : Event {
			return new CreatePopUpEvent(this.className, this.modal, this.width, this.height);
		}

	}

}