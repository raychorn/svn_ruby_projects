package com.pomodo.business {
    import com.adobe.cairngorm.business.ServiceLocator;
    import com.pomodo.model.Project;
    import mx.rpc.IResponder;
    import mx.rpc.remoting.RemoteObject;

    public class ProjectDelegate {
        private var _responder:IResponder;

        private var _projectRO:RemoteObject;
        
        public function ProjectDelegate(responder:IResponder) {
            _responder = responder;
            _projectRO =
                ServiceLocator.getInstance().getRemoteObject(
                    "projectRO");
        }
        
        public function listProjects():void {
            var call:Object = _projectRO.index.send();
            call.addResponder(_responder);
        }

        public function createProject(project:Project):void {
            var call:Object = _projectRO.create.send(
                project.toVO());
            call.addResponder(_responder);
        }

        public function updateProject(project:Project):void {
            var call:Object = _projectRO.update.send(
                project.toVO());
            call.addResponder(_responder);
        }

        public function destroyProject(project:Project):void {
            var call:Object =
                _projectRO.destroy.send(project.id);
            call.addResponder(_responder);
        }
    }
}