package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.NoteDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.model.Note;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.util.CairngormUtils;
    
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class UpdateNoteCommand implements ICommand,
    IResponder {
        public function UpdateNoteCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:NoteDelegate = new NoteDelegate(this);
            delegate.updateNote();
        }

        public function result(event:Object):void {
        }
    
        public function fault(event:Object):void {
        }
    }
}
