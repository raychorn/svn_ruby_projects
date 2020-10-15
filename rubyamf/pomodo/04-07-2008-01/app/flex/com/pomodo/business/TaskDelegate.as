package com.pomodo.business {
    import com.adobe.cairngorm.business.ServiceLocator;
    import com.pomodo.model.Task;
    
    import mx.rpc.IResponder;
    import mx.rpc.remoting.RemoteObject;

    public class TaskDelegate {
        private var _responder:IResponder;
        
        private var _taskRO:RemoteObject;
        
        public function TaskDelegate(responder:IResponder) {
            _responder = responder;
            _taskRO =
                ServiceLocator.getInstance().getRemoteObject(
                    "taskRO");
        }
        
        public function listTasks():void {
            var call:Object = _taskRO.index.send();
            call.addResponder(_responder);
        }

        public function createTask(task:Task):void {
            var call:Object = _taskRO.create.send(task.toVO());
            call.addResponder(_responder);
        }

        public function updateTask(task:Task):void {
            var call:Object = _taskRO.update.send(task.toVO());
            call.addResponder(_responder);
        }

        public function destroyTask(task:Task):void {
            var call:Object = _taskRO.destroy.send(task.id);
            call.addResponder(_responder);
        }
    }
}