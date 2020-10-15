package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.UserDelegate;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.model.User;
    import com.pomodo.validators.ServerErrors;
    
    import mx.controls.Alert;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class CreateUserCommand implements ICommand,
    IResponder {
        public function CreateUserCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:UserDelegate = new UserDelegate(this);
            delegate.createUser(event.data);
        }

        public function result(event:Object):void {
            var result:Object = event.result;
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            if (result is XML) {
                var resultXML:XML = XML(result);
                if (resultXML.name().localName == "errors") {
                    Alert.show(
"Please correct the validation errors highlighted on the form.",
"Account Not Created");
                    model.accountCreateErrors =
                        new ServerErrors(resultXML);
                } else {
                    model.user = User.fromXML(resultXML);
                    model.workflowState =
                        PomodoModelLocator.VIEWING_MAIN_APP;
                }
            } else {
                if (result == "error") {
                    Alert.show(
"There was an error creating your account. Please try again later.",
"Account Not Created");
                }
            }
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("CreateUserCommand#fault: " + event);
            Alert.show("Account Not Created", "Error");
        }
    }
}