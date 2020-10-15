package com.pomodo.util {
    import com.adobe.cairngorm.control.CairngormEvent;
    import mx.core.Application;

    public class CairngormUtils {
    	public static var parentApp:*;
    	
        public static function dispatchEvent( eventName:String, data:Object = null):void {
	//    	parentApp.services.modifyEndPoints();
            var event : CairngormEvent = new CairngormEvent(eventName);
            event.data = data;
            event.dispatch();
        }
    }
}
