package com.pomodo.business {
    import mx.rpc.IResponder;
    import com.pomodo.util.ServiceUtils;

    public class SessionDelegate {
        private var _responder:IResponder;
        
        public function SessionDelegate(responder:IResponder) {
            _responder = responder;
        }
        
        public function createSession(login:String,
        password:String):void {
            ServiceUtils.send(
                "/session.xml",
                _responder,
                "POST",
                {login: login, password: password});
        }
    }
}