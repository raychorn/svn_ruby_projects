package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.LocationDelegate;
    import com.pomodo.model.PomodoModelLocator;
    
    import mx.controls.Alert;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class ListLocationsCommand implements ICommand,
    IResponder {
        public function ListLocationsCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:LocationDelegate =
                new LocationDelegate(this);
            delegate.listLocations();
        }

        public function result(event:Object):void {
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            model.setLocationsFromVOs(event.result);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("ListLocationsCommand#fault: " + event);
            Alert.show("Locations could not be retrieved!");
        }
    }
}