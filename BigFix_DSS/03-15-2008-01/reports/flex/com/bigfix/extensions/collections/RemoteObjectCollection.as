/* This collection allows you to page through remote data. it has the following public vars you need to set
listMethod: an object of type 'mx.rpc.remoting.Operation' which will be executed to get rows. This method will receive 3 args, the remoteMethodArgs, limit, and offset respectively
countMethod: an object of type 'mx.rpc.remoting.Operation' which will be executed to get number of rows
remoteMethodArgs: this is a place where you can pass args to the methods above
pageLength: how many rows to chunk at a time, defaults to 100

Once you've instatiated this class, you can bind it to the dataProvider of a DataGrid or something similar
To refresh the list, just call RemoteObjectCollection.refresh

NOTE: ListCollectionView exposes methods for sorting. When these are called, your 'remoteMethodArgs' object will recieve a a property
called 'remote_object_collection_order_by' with a value of something like: '<column name> DESC'
*/

package com.bigfix.extensions.collections {
	import mx.collections.ListCollectionView;
	import mx.collections.IList;
	import mx.collections.SortField;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import com.bigfix.extensions.collections.RemoteObjectList;
	import mx.rpc.remoting.mxml.Operation;
	import flash.events.Event;
	import com.bigfix.dss.model.DSSModelLocator;

	public class RemoteObjectCollection extends ListCollectionView {
		/* track our instance of RemoteObjectList */
		private var _list:RemoteObjectList = new RemoteObjectList();

		/* Constructor */
		public function RemoteObjectCollection() {
			super(_list);
			_list.addEventListener("customReset", listResetChangeHandler, false, 0, true);
		}

		/* getters and setters */
		public function set listMethod(value:Operation):void {
			_list.listMethod = value;
		}
		public function get listMethod():Operation {
			return _list.listMethod;
		}
		public function set countMethod(value:Operation):void {
			_list.countMethod = value;
		}
		public function get countMethod():Operation {
			return _list.countMethod;
		}
		public function set remoteMethodArgs(value:*):void {
			_list.remoteMethodArgs = value;
			// INCOMPLETE: need to call internalRefresh or something...
		}
		public function get remoteMethodArgs():* {
			return _list.remoteMethodArgs;
		}
		public function set pageSize(value:int):void {
			_list.pageSize = value;
		}
		public function get pageSize():int {
			return _list.pageSize;
		}

		/* this method handles the 'customReset' event thrown from RemoteObjectList */
		private function listResetChangeHandler(event:Event):void {
			var newEvent:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			newEvent.kind = CollectionEventKind.RESET;
			dispatchEvent(newEvent);
		}

		override public function refresh():Boolean {
			var s:String;
			var newSortArgs:Array = [];
			if (sort) {
				for each (var sortField:SortField in sort.fields) {
					newSortArgs.push("`" + sortField.name + "` " + String((sortField.descending) ? 'DESC' : 'ASC'));
				}
				_list.sortArgs = newSortArgs;
			} else {
				_list.sortArgs = null;
			}
			_list.refresh();
			return true;
		}
	}
}