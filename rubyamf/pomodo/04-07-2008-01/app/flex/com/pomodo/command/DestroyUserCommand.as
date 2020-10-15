package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.UserDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.model.User;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.util.CairngormUtils;
    
    import mx.controls.Alert;
    import mx.core.Application;
    import mx.events.CloseEvent;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class DestroyUserCommand implements ICommand,
    IResponder {
        public function DestroyUserCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:UserDelegate = new UserDelegate(this);
            delegate.destroyUser(event.data);
        }

        public function result(event:Object):void {
            var resultEvent:ResultEvent = ResultEvent(event);
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            if (event.result == "success") {
                Alert.show(
                    "Your account was deleted.",
                    "Delete Successful",
                    Alert.OK,
                    Application(Application.application),
                    alertClickHandler);                
            } else {
                Alert.show(
                   "Your account was not successfully deleted.",
                   "Error");
            }
        }
        
        private function alertClickHandler(event:CloseEvent):
        void {
            CairngormUtils.dispatchEvent(EventNames.LOAD_URL,
                "http://www.flexiblerails.com");
        }        
    
        public function fault(event:Object):void {
            var faultEvent:FaultEvent = FaultEvent(event);
            Alert.show("The user was not successfully deleted.",
                "Error");
        }
    }
}