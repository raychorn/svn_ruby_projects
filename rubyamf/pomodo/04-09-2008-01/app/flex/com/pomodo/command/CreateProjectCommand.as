package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.ProjectDelegate;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.control.EventNames;
    import com.pomodo.util.CairngormUtils;
    
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class CreateProjectCommand implements ICommand,
    IResponder {
        public function CreateProjectCommand() {     
        }

        public function execute(event:CairngormEvent):void {
            var delegate:ProjectDelegate =
                new ProjectDelegate(this);
            delegate.createProject(event.data);
        }

        public function result(event:Object):void {
            CairngormUtils.dispatchEvent(
                EventNames.LIST_PROJECTS);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("CreateProjectCommand#fault: " +
                event);
        }
    }
}