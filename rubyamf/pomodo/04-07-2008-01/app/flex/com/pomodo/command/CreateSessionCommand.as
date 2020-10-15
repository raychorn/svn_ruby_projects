package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.SessionDelegate;
    import com.pomodo.business.TaskDelegate;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.model.User;
    
    import mx.controls.Alert;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class CreateSessionCommand implements ICommand,
    IResponder {
        public function CreateSessionCommand() {     
        }

        public function execute(event:CairngormEvent):void {
            var delegate:SessionDelegate =
                new SessionDelegate(this);
            delegate.createSession(event.data.login,
                event.data.password);
        }

        public function result(event:Object):void {
            var result:Object = event.result;
            if (event.result == "badlogin") {
                Alert.show("Login failed.");
            } else {
                var model:PomodoModelLocator =
                    PomodoModelLocator.getInstance();
                model.user = User.fromXML(XML(event.result));
                model.workflowState =
                    PomodoModelLocator.VIEWING_MAIN_APP;
            }
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("CreateSessionCommand#fault: " +
                event);
            Alert.show("Login Failed", "Error");
        }
    }
}