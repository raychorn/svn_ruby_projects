package customComponents.collections {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.rpc.remoting.RemoteObject;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.collections.errors.ItemPendingError;
	import mx.rpc.IResponder;
	import customComponents.objects.ComputerListOptions; // this should be replaced with a more generic customListFilter class which the computerListOptions extends... or something
	[Event(name="customReset")]
	public class RemoteObjectList extends Object implements IList {
		/**
		 *  @private
		 *  Internal event dispatcher.
		 */
		private var eventDispatcher:EventDispatcher;

		/**
		 * @private
		 * What we believe the length of the list to be (or -1 if not known).
		 */
		private var _length:int;

		/**
		 * @private
		 * Our cache of list values.
		 */
		private var cache:Array;

		/**
		 * @private
		 * Array mapping pending pages to the ItemPendingError that was issued.
		 */
		private var pagesPending:Array;

		/**
		 * @private
		 * Array of pages held in memory.
		 */
		private var pages:Array;

		/**
		 * @private
		 * Dictionary mapping async tokens to the page that was requested.
		 */
		private var pageTokens:Dictionary;

		/**
		 * How many records to prefetch.
		 */
		private var _pageSize:int = 100;
		/**
		 * vars for the remote object
		 */
		private var _remoteObject:RemoteObject;

		private var _filter:ComputerListOptions;
		//private var _destination:String;
		private var _listMethodName:String = "getList";
		private var _countMethodName:String = "getTotalRecords";

		private var _ready:Boolean = false;


		public function RemoteObjectList() {
			super();
			eventDispatcher = new EventDispatcher(this);
		}

		public function refresh():void {
			if (!(_remoteObject && _filter && _listMethodName && _countMethodName)) {
				throw new Error("RemoteObjectList isn't ready yet!");
			}
			attachEvents();
			pages = new Array();
			pageTokens = new Dictionary();
			cache = new Array();
			pagesPending = new Array();
			_length = -1;
			fetchLength();
		}

		/* Setters */
		public function set remoteObject(value:RemoteObject):void {
			trace("RemoteObjectList.remoteObject set");
			_remoteObject = value;
		}

		public function set pageSize(value:int):void {
			trace("RemoteObjectList.pageSize set");
			_pageSize = value;
		}

		public function set filter(value:ComputerListOptions):void {
			trace("RemoteObjectList.filter set");
			_filter = value;
		}

		public function set listMethodName(value:String):void {
			trace("RemoteObjectList.listMethod set");
			_listMethodName = value;
		}

		public function set countMethodName(value:String):void {
			trace("RemoteObjectList.countMethod set");
			_countMethodName = value;
		}


		/* Getters */
		public function get length():int
		{
			return _length;
		}
		public function get filter():ComputerListOptions {
			return _filter;
		}

		/* methods enforced by IList */
		public function getItemAt(index:int, prefetch:int=0):Object
		{
			var page:int = Math.floor(index / _pageSize);

			//trace("RemoteObjectList.getItemAt(", index, ",", prefetch, ")");

			if (index < 0 || index > _length)
				throw new RangeError("List index out of range.");

			if (this.pages[page] == null) {
				cacheMissAt(index);
				return null;
			}
			else
				return this.pages[page][index % _pageSize];
		}


		/* custom methods specific to this class */
		private function attachEvents():void {
			if (!_remoteObject[_listMethodName].hasEventListener(ResultEvent.RESULT)) {
				_remoteObject[_listMethodName].addEventListener(ResultEvent.RESULT, gotRows);
			}
			if (!_remoteObject[_listMethodName].hasEventListener(FaultEvent.FAULT)) {
				_remoteObject[_listMethodName].addEventListener(FaultEvent.FAULT, failedToGetRows);
			}
			if (!_remoteObject[_countMethodName].hasEventListener(ResultEvent.RESULT)) {
				_remoteObject[_countMethodName].addEventListener(ResultEvent.RESULT, gotLength);
			}
			if (!_remoteObject[_countMethodName].hasEventListener(FaultEvent.FAULT)) {
				_remoteObject[_countMethodName].addEventListener(FaultEvent.FAULT, failedToGetLength);
			}
		}

		private function cacheMissAt(index:int):void
		{
			trace("RemoteObjectList.cacheMissAt(", index, ")");

			var page:int = Math.floor(index / _pageSize);

			trace("pending", pagesPending[page]);

			if (pagesPending[page] == null)
				fetchPage(page)

			throw pagesPending[page];
		}

		private function fetchLength():void
		{
			trace("RemoteObjectList.fetchLength()");
			_remoteObject[_countMethodName].send(_filter);

		}

		private function fetchPage(page:int):void
		{
			trace("RemoteObjectList.fetchPage(", page, ")");
			pageTokens[_remoteObject[_listMethodName].send(page * _pageSize, _pageSize, _filter)] = page;
			pagesPending[page] = new ItemPendingError("Loading...");
		}

		private function gotLength(e:ResultEvent):void
		{
			trace("RemoteObjectList.gotLength()");
			/*
			trace(e.result.summary.count);
			this._length = e.result.summary.count;
			*/
			this._length = parseInt(e.result as String);
			trace("got length of ", this._length);
			fetchPage(0);
		}

		private function gotRows(e:ResultEvent):void
		{
			//var rows:Array = e.result.vulns.vuln.source;

			var page:int = pageTokens[e.token];
			trace("RemoteObjectList.gotRows() ", "for page: ", page);

			// Dispatch a reset event if this is the first bit of data we've loaded.
			var needReset:Boolean = pages.length == 0;

			pages[page] = e.result;

			var responders:Array = pagesPending[page].responders;
			if (responders is Array) {
				responders.forEach(function(item:IResponder, index:int, arr:Array):void
							   { trace("nulling something weird out"); item.result(null); });
			}

			pagesPending[page] = null;
			pageTokens[e.token] = null;

			if (needReset)
				notifyReset();
		}

		private function failedToGetRows(e:FaultEvent):void {
			trace("RemoteObjectList.failedToGetRows()");

			var page:int = pageTokens[e.token];
			var responders:Array = pagesPending[page].responders;

			if (responders is Array) {
				responders.forEach(function(item:IResponder, index:int, arr:Array):void { item.fault(e.fault) });
			}

			pagesPending[page] = null;
			pageTokens[e.token] = null;
		}

		private function failedToGetLength(e:FaultEvent):void
		{
			trace("RemoteObjectList.failedToGetLength()");
			trace(e);
		}

		private function notifyReset():void
		{
			trace("notifyReset()");
			/*
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.RESET;
			dispatchEvent(event);
			*/
			dispatchEvent(new Event("customReset"));
		}

		/* methods enforced by IEventDispatcher, simple passthroughs to the eventDispatcher property */
		public function hasEventListener(type:String):Boolean
		{
			return eventDispatcher.hasEventListener(type);
		}

		public function willTrigger(type:String):Boolean
		{
			return eventDispatcher.willTrigger(type);
		}

		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}

		public function dispatchEvent(event:Event):Boolean
		{
			return eventDispatcher.dispatchEvent(event);
		}

		/* methods enforced by IList but not implemented */
		public function addItemAt(item:Object, index:int):void
		{
			throw new Error("Not implemented");
		}

		public function toArray():Array
		{
			throw new Error("Not implemented");
			return null;
		}

		public function itemUpdated(item:Object, property:Object=null, oldValue:Object=null, newValue:Object=null):void
		{
			throw new Error("Not implemented");
		}

		public function removeAll():void
		{
			throw new Error("Not implemented");
		}

		public function getItemIndex(item:Object):int
		{
			throw new Error("Not implemented");
			return 0;
		}

		public function setItemAt(item:Object, index:int):Object
		{
			throw new Error("Not implemented");
			return null;
		}

		public function removeItemAt(index:int):Object
		{
			throw new Error("Not implemented");
			return null;
		}

		public function addItem(item:Object):void
		{
			throw new Error("Not implemented");
		}
	}
}

