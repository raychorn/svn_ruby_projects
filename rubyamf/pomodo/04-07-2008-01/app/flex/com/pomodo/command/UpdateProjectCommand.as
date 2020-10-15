package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.ProjectDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.util.CairngormUtils;
    
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class UpdateProjectCommand implements ICommand,
    IResponder {
        public function UpdateProjectCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:ProjectDelegate =
                new ProjectDelegate(this);
            delegate.updateProject(event.data);
        }

        public function result(event:Object):void {
            CairngormUtils.dispatchEvent(EventNames.LIST_TASKS);
            CairngormUtils.dispatchEvent(
                EventNames.LIST_PROJECTS);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("UpdateProjectCommand#fault: " +
                event);
        }
    }
}