package sho.events {
	import flash.events.Event;

	public class AutoCompletionResetEvent extends Event {

		public function AutoCompletionResetEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_AUTO_COMPLETION_RESET:String = "autoCompletionReset";
        
        override public function clone():Event {
            return new AutoCompletionResetEvent(type);
        }
	}
}