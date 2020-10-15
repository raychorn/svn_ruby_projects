package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.LocationDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.util.CairngormUtils;
    
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class UpdateLocationCommand implements ICommand,
    IResponder {
        public function UpdateLocationCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:LocationDelegate =
                new LocationDelegate(this);
            delegate.updateLocation(event.data);
        }

        public function result(event:Object):void {
            CairngormUtils.dispatchEvent(
                EventNames.LIST_LOCATIONS);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("UpdateLocationCommand#fault: " +
                event);
        }
    }
}