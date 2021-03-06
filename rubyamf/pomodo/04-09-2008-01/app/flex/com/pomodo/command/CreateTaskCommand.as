package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.TaskDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.util.CairngormUtils;
    
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class CreateTaskCommand implements ICommand,
    IResponder {
        public function CreateTaskCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:TaskDelegate = new TaskDelegate(this);
            delegate.createTask(event.data);
        }

        public function result(event:Object):void {
            CairngormUtils.dispatchEvent(EventNames.LIST_TASKS);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("CreateTaskCommand#fault: " + event);
        }
    }
}