package com.pomodo.business {
    import com.adobe.cairngorm.business.ServiceLocator;
    import com.pomodo.model.Location;
    import mx.rpc.IResponder;
    import mx.rpc.remoting.RemoteObject;

    public class LocationDelegate {
        private var _responder:IResponder;
        
        private var _locationRO:RemoteObject;
        
        public function LocationDelegate(responder:IResponder) {
            _responder = responder;
            _locationRO =
                ServiceLocator.getInstance().getRemoteObject(
                    "locationRO");
        }

        public function listLocations():void {
            var call:Object = _locationRO.index.send();
            call.addResponder(_responder);
        }

        public function createLocation(location:Location):void {
            var call:Object = _locationRO.create.send(
                location.toVO());
            call.addResponder(_responder);
        }

        public function updateLocation(location:Location):void {
            var call:Object = _locationRO.update.send(
                location.toVO());
            call.addResponder(_responder);
        }

        public function destroyLocation(location:Location):
        void {
            var call:Object =
                _locationRO.destroy.send(location.id);
            call.addResponder(_responder);
        }
    }
}