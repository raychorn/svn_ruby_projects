package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.TaskDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.model.Task;
    import com.pomodo.util.CairngormUtils;
    import com.pomodo.vo.TaskVO;

    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class UpdateTaskCommand implements ICommand,
    IResponder {
        public function UpdateTaskCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:TaskDelegate = new TaskDelegate(this);
            delegate.updateTask(event.data);
        }

        public function result(event:Object):void {
            var resultEvent:ResultEvent = ResultEvent(event);
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            model.updateTask(Task.fromVO(TaskVO(event.result)));
            CairngormUtils.dispatchEvent(
                EventNames.LIST_PROJECTS);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("UpdateTaskCommand#fault: " + event);
        }
    }
}