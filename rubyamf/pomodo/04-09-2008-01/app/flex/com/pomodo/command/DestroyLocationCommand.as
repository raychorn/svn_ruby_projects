package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.LocationDelegate;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.control.EventNames;
    import com.pomodo.util.CairngormUtils;
    
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class DestroyLocationCommand implements ICommand,
    IResponder {
        public function DestroyLocationCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:LocationDelegate =
                new LocationDelegate(this);
            delegate.destroyLocation(event.data);
        }

        public function result(event:Object):void {
            CairngormUtils.dispatchEvent(
                EventNames.LIST_LOCATIONS);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("DestroyLocationCommand#fault: " +
                event);
        }
    }
}