package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.TaskDelegate;
    import com.pomodo.model.PomodoModelLocator;
    
    import mx.controls.Alert;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class ListTasksCommand implements ICommand,
    IResponder {
        public function ListTasksCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:TaskDelegate = new TaskDelegate(this);
            delegate.listTasks();
        }

        public function result(event:Object):void {
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            model.setTasksFromVOs(event.result);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("ListTasksCommand#fault: " + event);
            Alert.show("Tasks could not be retrieved!");
        }
    }
}