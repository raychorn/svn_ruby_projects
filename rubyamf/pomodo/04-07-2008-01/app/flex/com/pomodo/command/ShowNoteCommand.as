package com.pomodo.command {
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import com.pomodo.business.NoteDelegate;
    import com.pomodo.control.EventNames;
    import com.pomodo.model.PomodoModelLocator;
    import com.pomodo.model.Note;
    import com.pomodo.util.CairngormUtils;
    
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    
    public class ShowNoteCommand implements ICommand,
    IResponder {
        public function ShowNoteCommand() {
        }

        public function execute(event:CairngormEvent):void {
            var delegate:NoteDelegate = new NoteDelegate(this);
            delegate.showNote();
        }

        public function result(event:Object):void {
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            model.note = Note.fromVO(event.result);
        }
    
        public function fault(event:Object):void {
        }
    }
}
