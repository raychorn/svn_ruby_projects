package com.bigfix.dss.view.editors.events {
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class OpenedRichTextEditorEvent extends Event {

		public function OpenedRichTextEditorEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
		
        public static const TYPE_OPENED_RICH_TEXT_EDITOR:String = "openedRichTextEditor";
        
        override public function clone():Event {
            return new OpenedRichTextEditorEvent(type);
        }
	}
}