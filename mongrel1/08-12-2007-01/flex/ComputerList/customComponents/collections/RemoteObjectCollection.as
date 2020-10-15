package customComponents.collections {
	import mx.collections.ListCollectionView;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import customComponents.collections.RemoteObjectList;
	import customComponents.objects.ComputerListOptions;
	import mx.rpc.remoting.RemoteObject;
	import flash.utils.*;
	import flash.events.Event;

	public class RemoteObjectCollection extends ListCollectionView {
		private var _list:RemoteObjectList = new RemoteObjectList();

		public function RemoteObjectCollection() {
			trace("RemoteObjectCollection constructor()");
			super(_list);

			_list.addEventListener("customReset", listResetChangeHandler, false, 0, true);
		}

		private function listResetChangeHandler(event:Event):void {
			trace("RemoveObjectCollection caught Custom RESET event");
			var newEvent:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			newEvent.kind = CollectionEventKind.RESET;
			dispatchEvent(newEvent);
		}

		override public function initialized(document:Object, id:String):void {
			trace("RemoteObjectCollection.initialized() called");
			// uncomment the next line when we're ready to actually query the server
			//_list.initialize();
		}

		public function set remoteObject(value:RemoteObject):void {
			trace("RemoteObjectCollection.remoteObject set");
			_list.remoteObject = value;
		}

		public function set pageSize(value:int):void {
			trace("RemoteObjectCollection.pageSize set");
			_list.pageSize = value;
		}

		public function set filter(value:ComputerListOptions):void {
			trace("RemoteObjectCollection.filter set");
			_list.filter = value;
			// INCOMPLETE: need to call internalRefresh or something...
		}

		public function get filter():ComputerListOptions {
			return _list.filter;
		}


		public function set listMethod(value:String):void {
			trace("RemoteObjectCollection.listMethod set");
			_list.listMethodName = value;
		}

		public function set countMethod(value:String):void {
			trace("RemoteObjectCollection.countMethod set");
			_list.countMethodName = value;
		}

		override public function refresh():Boolean {
			trace("RemoteObjectCollection.refresh() called");
			if (sort) {
				list['filter'].order_by = sort.fields[0].name + " " + String((sort.fields[0].descending) ? 'DESC' : 'ASC');
				trace("passing a sorting option of: ", list['filter'].order_by);
			}
			_list.refresh();
			return true;
		}
	}
}