package com.pomodo.business {
    import mx.rpc.IResponder;
    import com.pomodo.model.User;
    import com.pomodo.util.ServiceUtils;

    public class UserDelegate {
        private var _responder:IResponder;
        
        public function UserDelegate(responder:IResponder) {
            _responder = responder;
        }
        
        public function createUser(user:User):void {
            ServiceUtils.send("/users.xml", _responder, "POST",
                user.toXML(), true);
        }
        
        public function destroyUser(user:User):void {
            ServiceUtils.send("/users/" + user.id + ".xml",
                _responder, "DELETE");
        }
    }
}