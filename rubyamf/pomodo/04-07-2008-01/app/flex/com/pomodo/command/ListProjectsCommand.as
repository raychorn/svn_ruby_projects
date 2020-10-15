package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.ProjectDelegate;
    import com.pomodo.model.PomodoModelLocator;
    
    import mx.controls.Alert;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class ListProjectsCommand implements ICommand,
    IResponder {
        public function ListProjectsCommand() {     
        }

        public function execute(event:CairngormEvent):void {
            var delegate:ProjectDelegate =
                new ProjectDelegate(this);
            delegate.listProjects();
        }

        public function result(event:Object):void {
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            model.setProjectsFromVOs(event.result);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("ListProjectsCommand#fault: " + event);
            Alert.show("Projects could not be retrieved!");
        }
    }
}