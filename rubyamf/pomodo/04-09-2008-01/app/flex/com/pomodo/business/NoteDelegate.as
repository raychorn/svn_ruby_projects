package com.pomodo.business {
    import com.adobe.cairngorm.business.ServiceLocator;
    import com.pomodo.model.Note;
    import com.pomodo.model.PomodoModelLocator;
    import mx.rpc.IResponder;
    import mx.rpc.remoting.RemoteObject;

    public class NoteDelegate {
        private var _responder:IResponder;
        
        private var _noteRO:RemoteObject;

        public function NoteDelegate(responder:IResponder) {
            _responder = responder;
            _noteRO =
                ServiceLocator.getInstance().getRemoteObject(
                    "noteRO");
        }
        
        public function showNote():void {
            var call:Object = _noteRO.show.send();
            call.addResponder(_responder);
        }

        public function updateNote():void {
            var model:PomodoModelLocator =
                PomodoModelLocator.getInstance();
            var call:Object = _noteRO.update.send(
                model.note.toVO());
            call.addResponder(_responder);
        }
    }
}