package sho.events {
	import flash.events.Event;

	public class AutoCompletionDoneEvent extends Event {

		public function AutoCompletionDoneEvent(type:String, selectedIndex:int, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
			this.selectedIndex = selectedIndex;
		}
		
        public static const TYPE_AUTO_COMPLETION_DONE:String = "autoCompletionDone";
        
        public var selectedIndex:int;
        
        override public function clone():Event {
            return new AutoCompletionDoneEvent(type, selectedIndex);
        }
	}
}