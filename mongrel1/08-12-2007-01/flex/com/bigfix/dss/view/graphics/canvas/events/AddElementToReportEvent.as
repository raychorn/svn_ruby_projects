package com.bigfix.dss.view.graphics.canvas.events {
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.geom.Point;

	public class AddElementToReportEvent extends Event {

		public function AddElementToReportEvent(type:String, elementType:String, x:Number, y:Number, width:Number, height:Number, data:* = null, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.elementType = elementType;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
			this.data = data;
		}
		
        public static const TYPE_ADD_ELEMENT_TO_REPORT:String = "addElementToReport";
        
        public var elementType:String;
        public var x:Number;
        public var y:Number;
        public var width:Number;
        public var height:Number;
        public var data:*;

		override public function toString():String {
			return super.toString() + ", elementType=" + this.elementType + ", (" + this.x + "," + this.y + "), (" + this.width + " x " + this.height + ")";
		}
		
        override public function clone():Event {
            return new AddElementToReportEvent(type, elementType, x, y, width, height, data);
        }
	}
}