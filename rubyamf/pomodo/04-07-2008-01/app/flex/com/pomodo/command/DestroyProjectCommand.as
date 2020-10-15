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
    
    public class DestroyProjectCommand implements ICommand,
    IResponder {
        public function DestroyProjectCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:ProjectDelegate =
                new ProjectDelegate(this);
            delegate.destroyProject(event.data);
        }

        public function result(event:Object):void {
            CairngormUtils.dispatchEvent(
                EventNames.LIST_PROJECTS);
        }
    
        public function fault(event:Object):void {
            Pomodo.debug("DestroyProjectCommand#fault: " +
                event);
        }
    }
}