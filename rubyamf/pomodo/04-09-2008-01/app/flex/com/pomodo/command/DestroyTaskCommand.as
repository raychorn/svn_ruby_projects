package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.TaskDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.model.Task;
    import com.pomodo.vo.TaskVO;
    import com.pomodo.util.CairngormUtils;
    
    import mx.controls.Alert;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class DestroyTaskCommand implements ICommand,
    IResponder {
        public function DestroyTaskCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:TaskDelegate = new TaskDelegate(this);
            delegate.destroyTask(event.data);
        }

        public function result(event:Object):void {
            var resultEvent:ResultEvent = ResultEvent(event);
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            if (event.result == "error") {
                Alert.show(
                    "The task was not successfully deleted.",
                    "Error");
            } else {
                model.removeTask(
                    Task.fromVO(TaskVO(event.result)));
            }
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("DestroyTaskCommand#fault: " + event);
            Alert.show("The task was not successfully deleted.",
                "Error");
        }
    }
}