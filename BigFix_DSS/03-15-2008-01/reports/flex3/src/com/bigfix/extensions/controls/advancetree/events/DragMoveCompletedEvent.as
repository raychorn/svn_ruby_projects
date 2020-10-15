package com.bigfix.extensions.controls.advancetree.events {
	import flash.events.Event;

	public class DragMoveCompletedEvent extends Event {

		public function DragMoveCompletedEvent(type:String, destNode:XML, sourceNode:XML, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.destNode = destNode;
			this.sourceNode = sourceNode;
		}
		
        public static const TYPE_DRAG_MOVE_COMPLETED:String = "dragMoveCompleted";
        
        public var destNode:XML;
        public var sourceNode:XML;
        
        override public function clone():Event {
            return new DragMoveCompletedEvent(type, destNode, sourceNode);
        }
	}
}